# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

cmv_observables = tabPanel(
    "Observables", 
    tabsetPanel(
        tabPanel(
            'Overview',
            br(),
            fluidRow(        
                column(6,
                    p(paste0(
'The NLP module extracted ',
length(unique(d$observables$observable_value)), ' unique observables from the "ticket_notes" field ',
'of the tickets. Of these,  about ',
nrow(attributes(d$observable_similarities)$key),
' observables had a substantial Jaccard similarity with at least one other observable.')),
                    p(paste0(
'The fast-greedy cluster detection algorithm identified ',
max(d$observable_clusters$clust_clique_map$cluster),
' clusters of related observables.  The table to the right summarizes',
' the distribution of observables per cluster.')),
                    p(
'The similarity measure underlying the clusters assesses the similarity between two observables based on the number of tickets that mention both observables together.  (Similarily, for clustering tickets, we look only at the number of observables that both tickets mention.)')
                ),
                column(6,
                    tableOutput("CMV_obs_com_sizes")
                )
            )
        ),
        tabPanel(
            'Clusters table',
            br(),
            h4('Observables clusters table'),
            'Each row of the table summarizes a single cluster of observables.',
            br(),
            strong('Peak time'), ' is how many days ago the rate of appearance of these observables peaked.',
            br(),
            strong('Most recent'), ' is how many days ago a member of this cluster was last mentioned in a ticket.',
            br(),
            p(),
            'The table also displays the most common organization, observable type, and ticket category for each cluster',
            ' along with the corresponding percentages of cases that these made up.',
            br(),
            br(),
            dataTableOutput("CMV_obs_summaries")
        ),
        tabPanel(
            'Cluster detail',
            br(),
            numericInput("CMV_obs_cluster_index", 
                "Enter a cluster id (or select a row of the clusters table):", 
                value = 1),
            br(),
            dataTableOutput("CMV_obs_cluster_det")
        )
    )
)
