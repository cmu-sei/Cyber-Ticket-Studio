# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


source('tabs/cmv/tickets/detail_ui.R')

cmv_tickets = tabPanel(
    "Tickets", 
    tabsetPanel(
        tabPanel(
            'Overview',
            br(),
            fluidRow(        
                column(6,
                    p(paste0(
'The data contain ', nrow(d$tickets), ' tickets. Of these, about ',
nrow(attributes(d$ticket_similarities)$key), ' tickets had a substantial Jaccard',
' similarity with at least one other ticket.')),
                    p(paste0(
'The fast-greedy cluster detection algorithm identified ', 
sum(as.numeric(d$frequency_tables$ticket_cluster_sizes$Frequency)),
' clusters of related tickets.  The table to the right summarizes',
' the distribution of tickets per cluster.')),
                    p(
'The similarity measure underlying the clusters assesses the similarity between two tickets based on the number of observables that both tickets mention.')
                ),
                column(6,
                    tableOutput("CMV_ticket_com_sizes")
                )
            )
        ),
        tabPanel(
            'Clusters table',
            br(),
            h4('Tickets clusters/clusters table'),
            'Each row of the table summarizes a single cluster of tickets.',
            br(),
            strong('Peak time'), ' is how many days ago the rate of appearance of these tickets peaked.',
            br(),
            strong('Most recent'), ' is how many days ago the most recent member of this cluster appeared.',
            br(),
            p(),
            'The table also displays the most common organization and ticket category for each cluster',
            ' along with the corresponding percentages of cases that these made up.',
            br(),
            br(),
            dataTableOutput("CMV_ticket_summaries")
        ),
        cmv_tickets_detail
    )
)
