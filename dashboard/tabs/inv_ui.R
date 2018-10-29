# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


source('tabs/inv/inv_det_ui.R')
source('tabs/inv/inv_trends_ui.R')

tickets_view = tabPanel(
    "Tickets", 
    tabsetPanel(
        inv_trends_subview,
        tabPanel(
            "Table",
            sidebarLayout(
                sidebarPanel(
                    tags$head(
                        tags$style(type="text/css", "select { max-width: 240px; }"),
                        tags$style(type="text/css", ".span4 { max-width: 290px; }"),
                        tags$style(type="text/css", ".well { max-width: 280px; }")
                    ),
                    h2('Filters'),
                    tags$br(),
                    textInput('INV_regex', 
                        label='Search the ticket_notes (accepts wildcards & regex):',
                        value= '*'),
                    selectInput('INV_organization', 
                        label = "Select organization:",
                        choices = c('- all organizations -', d$frequency_tables$organizations$Organization), 
                        selected = '- all organizations -'),
                    selectInput('INV_ticket_category', 
                        label = "Select ticket category:",
                        choices = c('- all categories -', d$frequency_tables$categories[,'Category']), 
                        selected = '- all categories -')
                    #, width = 3
                ),
                mainPanel(
                    dataTableOutput('INV_table')
                )
            )
        ),  
        inv_det_subview
    ) # end tabsetpanel
) # end tabpanel
