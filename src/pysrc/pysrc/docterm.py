# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


import numpy as np
import pandas as pd
import pdb
from progress.bar import Bar
import time

from . import dbtools
from . import LSH
from . import munge
from . import similarities
from . import utils

class DocsTerms(object):
    ''' Keeps track of the relationships between "documents" and "terms" '''
    def __init__(self, doc_term, docs, terms, term_cutoff = None, verbose = 1):
        '''
        Args:
            doc_term (pandas DataFrame): contains a "documents" column and a "terms" column, and
                contains a row for each instance of document containing a term
            docs (string):  the name of the "documents" column of doc_term. This column should
                contain only an index for the documents - not actual documents
            terms (string):  the name of the "terms" column of doc_term
            term_cutoff (int): Exclude terms that appear in fewer than this many docs
        '''
        self._print = utils.make_verbose_printer(verbose)
        self.verbose = verbose

        if term_cutoff:
            self._print( 'Excluding terms that appear in fewer than ' + str(term_cutoff) + ' docs ...' )
            doc_term = munge.trim_by_count(doc_term, 'term', cutoff = term_cutoff, verbose = verbose)
            doc_term.index = xrange(doc_term.shape[0])

        self._print('Creating an explicit index on the terms ...')
        doc_term = doc_term.copy() # avoid warning about setting values on copy of a slice
        doc_term['term_idx'] = munge.indexer(doc_term[terms])['index']

        self._print('Listing all terms for each document ...')
        terms_per_doc = pd.DataFrame(
            [ (k, '-'.join([str(y) for y in sorted(v)]) )  for k ,v in
              doc_term.groupby(docs)["term_idx"] ]
        )
        terms_per_doc.columns = [docs, 'terms_per_doc']

        self._print('Identifying cliques, or collections of documents with equivalent sets of terms')
        terms_per_doc['clique'] = munge.indexer(terms_per_doc['terms_per_doc'])['index']
        # The values of 'clique' now index equivalence classes on the sets of terms per doc
        doc_clique_map = terms_per_doc[[docs, 'clique']]
        representatives = doc_clique_map.copy().sort_values('clique').drop_duplicates('clique')
        clique_term = representatives.merge(doc_term)[['clique', 'term_idx']]

        self._print('Listing all terms for each clique')
        terms_per_clique = {k: set(v) for k ,v in clique_term.groupby("clique")['term_idx']}
        self.doc_clique_map = doc_clique_map
        self.clique_term = clique_term
        self.terms_per_clique = terms_per_clique

    def find_nonzero_matches(self):
        ''' Find all pairs of cliques that share at least one term

        We will have dictionaries that index cliques by term (cpt) and terms by clique (tpc).
        This function finds all clique-clique pairs that are linked via terms (cpt <-> tpc)
        '''
        self._print = utils.make_verbose_printer(self.verbose)
        self._print('Exhaustively listing all nonzero similarity pairs')
        tpc = self.terms_per_clique
        cpt = {k: set(v) for k ,v in self.clique_term.groupby("term_idx")['clique']}
        pairs = set([])
        bar = Bar('Processing', max = len(tpc))
        for clique, terms in tpc.items():
            bar.next()
            related_cliques = reduce(set.union, [cpt[term] for term in terms])
            pairs.update([(clique, k) for k in related_cliques if clique < k])
            # - the 'clique < k' condition ensures that (1,2) and (2,1) don't both get stored.
            # - structuring pairs as a set ensures that it contains no duplicate pairs
        bar.finish()
        return pairs

    def find_candidate_clique_pairs(self, pair_finder = None, **args):
        if not pair_finder:
            self.pairs = np.array(list(self.find_nonzero_matches()))
        elif pair_finder == 'LSH':
            local_pairs = LSH.LSH(docs = self.terms_per_clique,
                                  vocab_size = self.clique_term['term_idx'].max() + 1,
                                  n_hashes = args['n_hashes'])
            self.pairs = np.array(list(local_pairs))
        else:
            raise Exception('invalide pair_finder argument')

    def compute_clique_similarities(self, sim_thresh, num_procs = None):
        assert self.clique_term.shape[0] == sum([len(x) for k ,x in self.terms_per_clique.iteritems()])
        if not len(self.pairs ) >0:
            print('WARNING: self.pairs does not exist; creating it now with exhaustive search')
            self.pairs = np.array(list(self.find_nonzero_matches()))
        sim_class = similarities.SetSimilarities(
            sets = self.terms_per_clique,
            cutoff = sim_thresh,
            num_procs = num_procs,
            verbose = self.verbose)
        sims_df = pd.DataFrame(sim_class.apply_similarity(self.pairs))
        if sims_df.shape == 0:
            print("There are no similarities; a possible explanation is that your sim_thresh is high enough to weed them out")
            pdb.set_trace()
        sims_df.columns = ['clique1', 'clique2', 'sim', 'count1', 'count2']
        self.sims_df = sims_df


def asDocTerm(data, kind, cutoff, verbose=1):
    ''' Format the tickets-observables table as a DocTerm data set '''
    try:
        assert set(data.columns) == set(['ticket_id', 'observable_value'])
    except:
        pdb.set_trace()
    if kind == 'tickets':
        data.rename(columns={'ticket_id': 'doc', 'observable_value': 'term'}, inplace=True)
    elif kind == 'observables':
        data.rename(columns={'ticket_id': 'term', 'observable_value': 'doc'}, inplace=True)
    data = data[['doc', 'term']]
    return DocsTerms(data, 'doc', 'term', term_cutoff=cutoff, verbose=verbose)

def build_similarities_tables(config, n_limit=-1, num_cores=None, verbose=True):
    '''
    Compute the sparse Jaccard similarities between
    (A) observables, based on the sets of tickets that mention each observable, and
    (B) tickets, based on the sets of observables that each ticket mentions.
    '''
    t0 = time.time()
    CONN = dbtools.connect(config.paths.db)
    printv = utils.make_verbose_printer(verbose)

    printv('Load the observables table ...')
    query = "SELECT ticket_id, observable_value FROM observables"
    data = pd.read_sql_query(query + dbtools.limit_suffix(n_limit), CONN)
    data.sort_values(by=['ticket_id', 'observable_value'], inplace=True)
    data.drop_duplicates(inplace=True)

    ######################
    ### tickets       ####
    printv('Cast the tickets (documents) and their observables (terms) as a sparse document-term matrix')
    DocTerm = asDocTerm(data.copy(), kind='tickets', cutoff=config.tickets.minimum_terms_per_doc, verbose=0)
    # Compute similarities
    DocTerm.find_candidate_clique_pairs()  # pair_finder = 'LSH', n_hashes = config.tickets.n_hashes
    DocTerm.compute_clique_similarities(config.tickets.sim_thresh, num_cores)
    print('Build the ticket_cliques and ticket_similarities tables in the database')
    try:
        dbtools.dataframe2sqlite(data=DocTerm.doc_clique_map, connection=CONN,
                                 table_name='ticket_cliques', verbose=True)
        dbtools.dataframe2sqlite(data=DocTerm.sims_df, connection=CONN,
                                 table_name='ticket_similarities', verbose=True)
    except:
        pdb.set_trace()

    ######################
    ### observables   ####
    printv('Cast the observables (documents) and their tickets (terms) as a sparse document-term matrix ')
    DocTerm = asDocTerm(data.copy(), kind='observables', cutoff=config.observables.minimum_terms_per_doc)
    # Compute similarities
    DocTerm.find_candidate_clique_pairs()
    DocTerm.compute_clique_similarities(config.observables.sim_thresh, num_cores)
    print('Build the observable_cliques and observable_similarities tables in the database')
    try:
        dbtools.dataframe2sqlite(data=DocTerm.doc_clique_map, connection=CONN,
                                 table_name='observable_cliques', verbose=True)
        dbtools.dataframe2sqlite(data=DocTerm.sims_df, connection=CONN,
                                 table_name='observable_similarities', verbose=True)
    except:
        pdb.set_trace()

    printv('Total time to build similarities tables = ' + str(round(time.time() - t0)) + ' seconds')

