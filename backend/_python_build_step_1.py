# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

"""
This pushes raw data to an sqlite3 database

Starting point:  pre-formatted csv file with specified headers and data types
Ending point:  a database that contains separate tables for tickets and their extracted observables
"""
from __future__ import print_function
import pandas as pd

from pysrc import config
from pysrc import dbtools
from pysrc import docterm
from pysrc import observables

# CONFIG
conf = config.Config()
CONF = conf.cfg
NUM_CORES = 2
N_LIMIT = -1
VERBOSE = True

# Initialize DB
print('initializing/overwriting the sqlite3 db, ' + CONF.paths.db)
conn = dbtools.initialize_overwrite(CONF.paths.db)

dbtools.list_tables(conn)

# Build the tickets table
dbtools.dataframe2sqlite(
    data = conf.data_home_plus('tickets.csv'),
    connection = conn,
    table_name = 'tickets',
    index_fields = CONF.schema.tickets_fields_to_index,
    verbose = VERBOSE)

# Build the observables table #conn = dbtools.connect(CONF.paths.db)
print('extracting the observables from the tickets.ticket_notes ...')
tickets = pd.read_sql_query("SELECT ticket_id, ticket_notes FROM tickets", conn)
regex_types = ['ipv4addr', 'email', 'filename', 'fqdn']
df_list = []
for r in regex_types:
    print('extracting observables of type ' + r)
    df_list.append(observables.extract_from_notes(tickets, r))
df = pd.concat(df_list)
dbtools.dataframe2sqlite(
    data = df,
    connection = conn,
    table_name = 'observables',
    index_fields = CONF.schema.observables_fields_to_index,
    verbose = VERBOSE)

# Compute the sparse Jaccard similarities between observables and between tickets
docterm.build_similarities_tables(config = CONF, n_limit = N_LIMIT, num_cores = NUM_CORES)
