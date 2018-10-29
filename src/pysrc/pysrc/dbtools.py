# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


#########################
# Standard imports
import os
import pandas as pd
import pdb
import sqlite3

from . import utils

def limit_suffix(n):
    ''' For post-pending on an sqlite query'''
    if n >= 0:
        return ' LIMIT ' + str(N_LIMIT)
    else:
        return ''

def list_tables(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    print(cursor.fetchall())

def initialize_overwrite(path):
    if os.path.isfile(path):
        os.remove(path)
    connection = sqlite3.connect(path)
    connection.text_factory = str
    return connection

def connect(path):
    connection = sqlite3.connect(path)
    connection.text_factory = str
    return connection

def create_indices(conn, table_name, fields_to_index):
    ''' Puts indices on an sqlite3 database
    
    Args:
        conn: a connection to the database
        table_name:  the table to index
        fields_to_index: a list
    '''
    c = conn.cursor()
    for field in fields_to_index:
        c.execute('CREATE INDEX ' + table_name + '_idx_' + field + ' ON ' +
                   table_name + '(' + field + ');')
    
    conn.commit()

def dataframe2sqlite(data, connection, table_name, index_fields = None, verbose = False):
    '''

    :param data (string or pandas.DataFrame): Data, specified as a filepath to a csv or
    as a data frame.
    :param connection: A sqlite3 database connection
    :param table_name: (string) The name of the table to create in the database
    :param index_fields: (list of strings) Which fields to add indices for, if any
    :param verbose:
    :return: no return
    '''
    vprint = utils.make_verbose_printer(verbose)

    if isinstance(data, str):
        vprint('loading' + data + ' as pandas.DataFrame ...')
        df = pd.read_csv(data)
    else:
        df = data

    vprint('inserting the dataframe into the db as table ' + table_name + ' ...')
    df.to_sql(name=table_name, con=connection, index=False)

    if index_fields is not None:
        vprint('creating indices on the ' + table_name + ' table ...')
        create_indices(connection, table_name, index_fields)

    vprint("DONE adding data to the " + table_name + " table")