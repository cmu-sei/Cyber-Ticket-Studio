# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

import itertools
import pandas as pd
import pdb

import extract # SEI repo

def extract_from_notes(tickets, regex_type):
    '''
    Extract a particular type (specific regex) of observables from the ticket_notes
    :param tickets: (pandas.DataFrame) basically the tickets table from the db
    :param regex_type: (string) The kind of regex to apply form the `extract` module
    :return:
    '''
    def extract_on_row(row):
        values = extract.extract(row['ticket_notes'], regex_type)
        return [(row['ticket_id'], regex_type, value) for value in values]
    
    tickets.dropna(inplace = True)
    series = [extract_on_row(tickets.iloc[k]) for k in range(tickets.shape[0])]
    tuples = list(itertools.chain.from_iterable(series))
    df = pd.DataFrame(tuples)
    df.columns = ['ticket_id', 'observable_type', 'observable_value']
    return df


# '''
# Functions that carry out various stages of the comdetect pipeline for detecting
#     communities of observables based on co-ticket presence in tickets
# '''
# import igraph
# import numpy as np
# import pandas as pd
# import pdb
# from time import time
#
# from comdetect.lib import munge
# from comdetect.lib import similarities
# import gtpipeline.lib.dbTools as dbTools
#
# def select_data(db_pth, query, obs_cutoff, inc_cutoff_lower, inc_cutoff_upper):
#     print 'Load the tickets and their observables'
#     inc_obs = pd.read_sql_query(query, dbTools.connect(db_pth))
#     print 'Exclude observables that appear in fewer than ' + str(obs_cutoff) + ' tickets'
#     inc_obs = munge.trim_by_count(inc_obs, 'observable_value', cutoff = obs_cutoff)
#     print 'Exclude tickets that contain fewer than ' + str(inc_cutoff_lower) + ' observables'
#     inc_obs = munge.trim_by_count(inc_obs, 'ticket_id', cutoff = inc_cutoff_lower)
#     print 'Exclude tickets that contain more than ' + str(inc_cutoff_upper) + ' observables'
#     inc_obs = munge.trim_by_count(inc_obs, 'ticket_id', cutoff = inc_cutoff_upper, side = 1)
#     inc_obs.index = xrange(inc_obs.shape[0])
#     return inc_obs
#
# def make_minhash_signatures(inc_obs, n_hashes):
#     print 'Define integer indices for the ticket_id values'
#     indexer = munge.indexer(inc_obs['ticket_id'])
#     inc_lookup = indexer['lookup']
#     inc_obs['inc'] = indexer['index']
#     print 'Create a dictionary that lists all tickets for each observable'
#     obs_inc_dict = {k: set(v) for k,v in inc_obs.groupby("observable_value")["inc"]}
#     print 'Create the minhash signatures matrix (may take a few minutes) ...'
#     print '... with ' + str(inc_obs.shape[0]) + ' ticket-observables pairs, experience says '
#     print '   this should take about ' + str(round(0.5 * inc_obs.shape[0]/1000)) + ' seconds to finish'
#     vocab_size = inc_obs['inc'].max() + 1
#     Hashes = similarities.RandomHashes(n_hashes, vocab_size)
#     t0 = time()
#     signatures, obs = similarities.minhash(obs_inc_dict, vocab_size, hasher = Hashes.hasher)
#     print '... that took ' + str(round(time() - t0)) + ' seconds'
#     return {'obs': obs, 'sig': signatures, 'obs_inc_dict': obs_inc_dict, 'inc_lookup': inc_lookup}
#
# def make_similarities(minhash_results, sim_thresh):
#     sig = minhash_results['sig']
#     obs = minhash_results['obs']
#     obs_inc = minhash_results['obs_inc_dict']
#     obs_inc_by_int = {k: obs_inc[obs[k]] for k in xrange(len(obs))}
#     print 'Identify groups of potentially similar observables using LSH'
#     lsh_groups = similarities.lsh_matcher(sig)
#     print 'Compute the similarities on all pairs of potentially similar observables based on the groups above'
#     sim_class = similarities.SetSimilarities(sets = obs_inc_by_int, cutoff = sim_thresh)
#     print ' ... deduplicate the candidate pairs'
#     pairs = similarities.unique_pairs_in_groups(lsh_groups)
#     print ' ... compute similarity of each pair'
#     sims_df = pd.DataFrame(sim_class.apply_similarity(pairs))
#     sims_df.columns = ['sig_col_1', 'sig_col_2', 'sim']
#     print 'Keep track of the relationships between indices'
#     paired_obs_idx = pd.concat([sims_df['sig_col_1'], sims_df['sig_col_2']]).unique()
#     paired_obs = [obs[k] for k in paired_obs_idx]
#     obs_df = pd.DataFrame({'obs_sig_idx': paired_obs_idx, 'values': paired_obs})
#     obs_df['idx'] = obs_df.index
#     obs_df['idx1'] = obs_df['idx']
#     obs_df['idx2'] = obs_df['idx']
#     obs_df['sig_col_1'] = obs_df['obs_sig_idx']
#     obs_df['sig_col_2'] = obs_df['obs_sig_idx']
#     sims_df = sims_df.merge(obs_df[['idx1', 'sig_col_1']], how = 'left')
#     sims_df = sims_df.merge(obs_df[['idx2', 'sig_col_2']], how = 'left')
#     return {'sims': sims_df, 'obs': obs_df[['values', 'idx']], 'n_candidate_pairs': len(pairs)}
#
# def find_fastgreedy_igraph_communities(sims, obs):
#     ''' Create a similarities graph and decompose it using fastgreedy
#
#     Args:
#         sims (pandas DataFrame): Contains edges defined by the ['idx1', 'idx2']
#             pair of columns, and contains a similarity measures column 'sims'
#         obs (pandas DataFrame): Links the unique observables with the vertex
#             indices
#     Returns: A list of igraph subgraphs
#     '''
#     sim_graph = igraph.Graph(n = obs.shape[0])
#     sim_graph.add_edges([ tuple(x) for x in sims[['idx1', 'idx2']].values ])
#     sim_graph.vs['index'] = obs['idx']
#     sim_graph.vs['labels'] = obs['values']
#     sim_graph.es["weight"] = sims['sim']
#     communes = sim_graph.community_fastgreedy(weights='weight'
#                     ).as_clustering().subgraphs()
#     return communes
#
#
#
