# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

import itertools as it
from math import ceil as ceiling
import numpy as np
import pdb
from progress.bar import Bar
import random
from time import time
import warnings

from . import utils

class RandomHashes(object):
    def __init__(self, n_hashes, vocab_size, method = None, verbose = 1):
        ''' 
        Args:
            n_hashes (int): how many hash functions to generate
            vocab_size (int): the number of distinct items in the union of all docs
            method (string): if 'None', defaults to full random permutation.  If 'ax_plus_b',
                approximates a random permutation as ax + b modulo vocab size
            verbose (0 or 1):  if 0, don't print status updates
        '''
        self.n_hashes = n_hashes
        self.vocab_size = vocab_size
        self.method = method

        if method == 'ax_plus_b':
            self.coefficients = [(random.randint(1,n_hashes), 
                                  random.randint(1,n_hashes)) for i in xrange(n_hashes)]
        else:
            if (vocab_size > 10**6):
                warnings.warn("Consider using some approximation of random permutation; this will " +
                              "take a while because the vocab_size is so large")
            self.random_permutations = [np.random.permutation(self.vocab_size) for
                                        k in xrange(n_hashes)]
        
    def _kth_hash(self, x, k):
        if self.method == 'ax_plus_b':
            a = self.coefficients[k][0]
            b = self.coefficients[k][1]
            return (a * x + b) % self.vocab_size
        else: 
            return self.random_permutations[k][x]
    
    def hasher(self, x):
        return [self._kth_hash(x,k) for k in xrange(self.n_hashes)]
    
    
def minhash(docs, vocab_size, hasher):
    ''' Compute the minhash signature matrix for a data set.
    
    Args:
        docs (dict):  Each key corresponds to a high-dimensional data point, such 
            as a text or image.  The contents for a key is a set of integers 
            corresponding to the set of items contained in that data point.
        hasher (function): given an int, returns a list of int-valued hashes
        
    Returns:
        - a numpy array with i,jth element equal to the minhash value of the ith
            hash (of hasher) over the set of integers in the jth position of x.
        - a list of x's keys in the order that matches the columns of the array
    '''
    n_hashes = len(hasher(0))
    n_docs = len(docs)
    signatures = np.ones((n_hashes, n_docs), dtype='i') * 1e9
    keys = docs.keys()
    # verify that the columns of sig match with the keys
    #   (allegedly nothing guarantees .keys() to return a particular order)
    assert keys == list(xrange(n_docs)) 
    bar = Bar('Processing', max=n_docs)
    hashes_dict = {k: hasher(k) for k in range(vocab_size)} 
    for col in xrange(n_docs): # col indexes docs
        for term in docs[keys[col]]:
            signatures[:,col] = np.minimum(signatures[:,col], hashes_dict[term])
        bar.next()
    bar.finish()
    return signatures, keys


def lsh_matcher(signatures, rows_per_band = 5):
    ''' Use locality-sensitive hashing to find candidate pairs
    
    LSH finds candidate related incidents. For each band, it hashes each column
    into a big hash table. Any two columns (observations/documents) that hash 
    to the same bucket for any band are a candidate pair.
    
    Args: 
        signatures (numpy 2-d array): A row for each hash and a column for
            each observation.
        rows_per_band (int): 5 by default.  If the number of rows of signatures
            is not a multiple of rows_per_band, the final band will have fewer
            rows than any preceding bands.
        
    Returns: a list of candidate groups.  The i-th element of the list is a
        set of integers drawn from the column numbers of signatures 
    '''
    n_hashes = signatures.shape[0]
    n_bands = int(ceiling(n_hashes/float(rows_per_band)))
    candidate_groups = []
    for b in xrange(n_bands):
        band_start = rows_per_band*b
        band_end = min(n_hashes, band_start + rows_per_band)
        hash_bins = {}
        for col in xrange(signatures.shape[1]):
            h = hash(tuple(signatures[band_start:band_end,col]))
            if h not in hash_bins:
                hash_bins[h] = []
            hash_bins[h].append(col)
        for key, bin in hash_bins.iteritems():
            if len(bin) > 1:
                candidate_groups.append(bin)
    return candidate_groups

def unique_pairs_in_groups(groups, verbose = 0):
    ''' Each group in groups implies many pairs.  Make a list of all unique pairs.
    '''
    _print = utils.make_printer(verbose)
    gross_pairs = 0
    n_to_check = len(groups) #sum([ (len(g)**2)/2 for g in groups])  
    bar = Bar('Processing', max=n_to_check)
    pairs = set()
    for group in groups:
        bar.next() 
        new_pairs = list(it.combinations(group, 2))
        pairs.update(new_pairs)
    bar.finish()
    _print( "raw pairs: %d actual pairs: %d"%(gross_pairs,len(pairs)) )
    return set(pairs)

def pairs_gen(groups):
    for group in groups:
        for i in it.combinations(group,2):
            yield i

def LSH(docs, vocab_size, n_hashes, verbose = 0):
    ''' Perform locality sensitive hashing 
    
    Args:
        docs (dict): Each entry of the dict is a set of indices (which represent 'terms')
        vocab_size (int): the number of distinct items in the union of all docs
        n_hashes (int): how many hash functions to generate
    
    Returns:
        
    '''
    _print = utils.make_printer(verbose)
    assert sorted(docs.keys()) == list(xrange(len( docs.keys() )))
    sum_set_sizes = sum([len(x) for k,x in docs.iteritems()])
    _print ( 'Create the minhash signatures matrix ...' )
    #   _print  ('... with ' + str(sum_set_sizes) + ' doc-term pairs, this may take about ' + 
    #            str(sum_set_sizes/2000) + ' seconds')
    #   t0 = time()
    Hashes = RandomHashes(n_hashes = n_hashes, vocab_size = vocab_size)
    sig, sig_key = minhash(docs, vocab_size, hasher = Hashes.hasher)
    #     _print  '... that took ' + str(round(time() - t0)) + ' seconds'
    
    _print ( 'Identify groups of potentially similar cliques using LSH' )
    lsh_groups = lsh_matcher(sig) #sizes = [len(x) for x in lsh_groups]
    
    _print ( 'Based on these groups, return all [unique] candidate pairs of cliques' )
    t0 = time()
    return unique_pairs_in_groups(lsh_groups)
    #return pairs_gen(lsh_groups)
    _print ( '... that took ' + str(round(time() - t0)) + ' seconds' )
