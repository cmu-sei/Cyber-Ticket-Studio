# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


# The shiny app loads only static .RDS files for efficiency.  To keep up-to-date,
# it is occasionally necessary to rebuild these source files.  Simply source this
# script to rebuild some or all of the source files.
rm(list = ls()) #library(data.table)
library(RSQLite)
library(rsrc)

# Configure:
CONF = rsrc::get_config()
db_pth = file.path(CONF$dirs$datdir, "cyber_ticket_studio.database")
CONN = DBI::dbConnect(RSQLite::SQLite(), dbname = db_pth) #dbListTables(CONN)

######################
#### TICKETS
print('Load tickets and similarities between ticket cliques')
tickets = rsrc::load_tickets(CONN)
ticket_similarities = rsrc::load_similarities(CONN, "ticket")
print('Cluster the cliques of tickets and append cluster label to tickets:')
clique_clusters = rsrc::cluster(ticket_similarities)
ticket_clusters = rekey(attributes(ticket_similarities)$key, clique_clusters)
tickets = merge(tickets, ticket_clusters$clust_doc_map, by = 'ticket_id', all.x = TRUE)
print('Tabling summaries of the tickets clusters')
ticket_clusters$summaries = rsrc::summarize_clusters(
    tickets, ticket_clusters, kind = 'ticket')
# 
# ticket_clusters$summaries = rsrc::summarize_ticket_clusters(
#     tickets, ticket_clusters)

######################
#### OBSERVABLES
print('Load observables and similarities between observable cliques')
observables = rsrc::load_observables(CONN)
observable_similarities = rsrc::load_similarities(CONN, kind = 'observable')
print('Cluster the cliques of observables and append cluster label to observables')
clique_clusters = rsrc::cluster(observable_similarities)
observable_clusters = rekey(attributes(observable_similarities)$key, 
                               clique_clusters)
observables = merge(observables, observable_clusters$clust_doc_map, 
                    by = 'observable_value', all.x = TRUE)
print('Tabling summaries of the observables clusters')
observable_clusters$summaries = rsrc::summarize_clusters(
    observables, observable_clusters, kind = 'observable')

# construct a single huge list of all static app data
D = list(
    tickets = tickets,
    ticket_similarities = ticket_similarities,
    ticket_clusters = ticket_clusters,
    observables = observables,
    observable_similarities = observable_similarities,
    observable_clusters = observable_clusters
)
D$frequency_tables = rsrc::make_frequency_tables(D)

saveRDS(D, file = file.path(CONF$dirs$datdir, "data.RDS"))
