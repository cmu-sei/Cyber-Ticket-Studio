# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


import pdb
import time
import multiprocessing

from . import utils

#########################################################################################
# Using global variables helped to speed up the multiprocessing code by eliminating 
#   serialization of data
global SETS
global PAIRS
# MUTEX will enforce some synchronization on the apply_similarities() method to protect 
#   the global variables
global MUTEX
MUTEX = multiprocessing.Lock()
#########################################################################################

class SetSimilarities(object):
    def __init__(self, sets, similarity = None, cutoff = 0, num_procs = None, verbose = 1):
        ''' Various functions for computing pairwise similarities among sets
        
        Args:
            sets (dict): Contains sets of non-negative integers
            similarity (function): computes similarity between two sets. If not
                specified, defaults to SetSimilarities.jaccard
            cutoff (float): if the similarity is SetSimilarities.jaccard, any
                value below cutoff gets rounded to zero
        '''
        self._print = utils.make_verbose_printer(verbose)
        self.sets = sets
        if similarity:
            self.similarity = similarity
        else:
            self.similarity = jaccard
        self.cutoff = cutoff
        self.num_procs = num_procs 
   
    def apply_similarity(self, pairs):
        ''' Compute similarities for all given pairs
        
        Args:
            pairs (list of tuples): each tuple contains two indices for two sets
                in self.sets
        
        Returns: a list of all computed tuples (i, j, similarity(set_i, set_j))
            for which the similarity is above self.cutoff
        '''
        self._print('Compute similarities on all candidate pairs ...')
        self._print('... Setting values for the global variables ...')
        global SETS
        global PAIRS
        global MUTEX
        # acquire the lock to block reentrant calls
        MUTEX.acquire()
        SETS = self.sets
        PAIRS = pairs
        #self._print('... predicting this will take about ' + str(len(pairs)/30000.0) + ' seconds')
        t0 = time.time()
        work_pool = multiprocessing.Pool()
        if self.num_procs:
            work_pool._processes = self.num_procs
        else:
            work_pool._processes = max(1, work_pool._processes - 2)
        
        self._print("... computing similarities using " + 
                        str(work_pool._processes) + " processes ...")
        results = work_pool.imap_unordered(
            func = _get_similarity_worker(self.cutoff,self.similarity),
            iterable = xrange(len(pairs)),
            chunksize = 1000)
        self._print("... waiting for workers to finish ...")
        work_pool.close()
        work_pool.join()
        self._print("... filtering results...")
        # similarities that don't make the cutoff are represented in the results as None, strip them out here
        similarities = [ i for i in results if i is not None]
        self._print('... END SIMILARITY COMPUTATION that took ' + str(round(time.time() - t0)) + ' seconds')
        MUTEX.release()
        return similarities

class _get_similarity_worker(object):
    """A callable class to pass configuration information to and call the similarity method from child processes"""
    def __init__(self, cutoff, similarity):
        self.cutoff = cutoff
        self.similarity = similarity
    def __call__(self, pair_idx):
        global SETS
        global PAIRS
        pair = PAIRS[pair_idx]
        s1, s2 = SETS[pair[0]], SETS[pair[1]]
        n_s1, n_s2 = len(s1), len(s2)
        sim = self.similarity(n_s1, n_s2, len(s1.intersection(s2)) )
        if sim > self.cutoff:
            return (pair[0],pair[1], sim, n_s1, n_s2)


def jaccard(n_s1, n_s2, n_intersect):
    ''' The Jaccard similarity of two sets '''
    return n_intersect/float(n_s1 + n_s2 - n_intersect)
