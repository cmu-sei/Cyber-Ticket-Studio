# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


cmv_tickets_detail = tabPanel(
    'Cluster detail',
    br(),
    fluidRow(    
        column(3,
            numericInput("CMV_ticket_cluster_index", 
                "Enter a cluster id (or select a row of the clusters table):", 
                value = 1)
        ),
        column(3,
            dateRangeInput("cmv_ticket_cluster_date_range", 
            label = "Date range",
            start = d$metadata$time_start, end = d$metadata$time_end)
        )
    ),
    br(),
    tabsetPanel(
        tabPanel(
            'Table',
            dataTableOutput("CMV_ticket_cluster_det")
        ),
        tabPanel('Volume trends',
            br(),
            fluidRow(    
                column(3,
                    radioButtons("cmv_ticket_detail_breakoutby", 
                        label = "Breakout variable",
                        choices = list("-None-" = "NULL",
                                       "Organization" = 'ticket_organization', 
                                       "Category" = 'ticket_category'), 
                        selected = "NULL")
                )
            ),
            plotOutput("CMV_ticket_breakout_over_time", height = "700px")
        )
    )
)
