# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

import pandas as pd
import pdb

from . import utils

def trim_by_count(df, target, cutoff, side = 0, verbose = 1):
    ''' Remove all rows that contain too many or two few of a value in a given column
    
    Args:
        df (pandas DataFrame)
        target (string):  the name of a column of df.    
        cutoff (int): defines "too few" or "too many"
        side (boolean):  if 0, remove cases of frequency less than cutoff;
                         if 1, ..........................greater ........
    '''
    _print = utils.make_verbose_printer(verbose)
    counts = df[target].value_counts()
    if side:
        counts = counts[counts < cutoff]
    else:    
        counts = counts[counts > cutoff]
    keepers = df[target].isin(counts.index.values)
    _print(' ... dropping ' + str(df.shape[0] - sum(keepers)) + ' rows; '
            + str(sum(keepers)) + ' rows remain')
    return df[keepers]


def indexer(series):
    '''Create an index for the unique values of series 
    
    series must be of type pandas Series.  The index of series must be sorted
    and contiguious
    
    Example:  if series = ['a', 'b', 'c', 'b'], the return  [1, 2, 3, 2]
    
    Returns: a dict including the the index and its reverse lookup
    '''
    assert series.index.is_monotonic
    assert series.shape[0] == 1+series.index.max()
    unique_values = series.unique()
    unique_values = pd.DataFrame({'int': xrange(len(unique_values)), 'series': unique_values})
    lookup = {k: unique_values.series[k] for k in xrange(unique_values.shape[0])}
    df = pd.DataFrame({'series': series.values, 'series_index': xrange(series.shape[0])} )
    df = df.merge(unique_values)
    df.sort_values('series_index', inplace = True)
    return {'index': df['int'].values, 'lookup': lookup}

