# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

###
### summarize/dissect the clusters of tickets

source('tabs/cmv/tickets/detail_server.R', local = TRUE)

# Table of the distribution of cluster sizes:
output$CMV_ticket_com_sizes = shiny::renderTable(
    {d$frequency_tables$ticket_cluster_sizes}, 
    include.rownames=FALSE)


# Basic summaries of each cluster:
ticket_clust_summaries = d$ticket_clusters$summaries
setkey(ticket_clust_summaries, 'cluster id')
output$CMV_ticket_summaries = DT::renderDataTable(
    ticket_clust_summaries,
    selection = list(mode='single'),
    options = list(
            lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
            pageLength = 10, 
            searching = FALSE,
            autoWidth = TRUE #
    ),
    rownames = FALSE,
    server = TRUE
)
