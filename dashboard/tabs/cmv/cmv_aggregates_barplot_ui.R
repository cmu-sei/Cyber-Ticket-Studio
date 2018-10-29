# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

cmv_ticket_obs_relationships = tabPanel(
    "Ticket-observable relationships", 
    br(),
    p('The plot below shows the frequency distribution of the number of distint tickets that mention an observable (or the converse, if you select ticket_id).  For example, with the default settings, the sum of the heights of all the bars is equal to the number of distinct observables. In particular, there were on the order of 50 thousand observables that appeared in exactly two tickets, while only a handful of observables appeared in more than 50 tickets.'),
    fluidRow(        
        column(3,
            selectInput('CMV_ticket_or_obs', 
                label = "Compute frequencies for:",
                choices = c('observable_value', 'ticket_id'), 
                selected = 'ticket_id')
            ),
        column(3,
            selectInput('CMV_organization', 
                label = "Restrict by organization:",
                choices = c('- all organizations -', d$frequency_tables$organizations$Organization), 
                selected = d$frequency_tables$organizations$Organization[1])
        ),
        column(3,
            selectInput('CMV_obs_type', 
                label = "Restrict by observable type:",
                choices = c('- all types -', d$frequency_tables$observable_types[,'Observable type']), 
                selected = '- all types -')
        ),
        column(3,
            selectInput('CMV_include_bin1', 
                label = "Exclude the first bin?",
                choices = c('no', 'yes'), 
                selected = 'no')
        )
    ),
    plotOutput('CMV_aggregate_barplot')
)
