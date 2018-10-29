# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


inv_trends_subview = tabPanel(
    "Trends", 
    br(),
    sidebarLayout(
        sidebarPanel(
            tags$head(
                tags$style(type="text/css", "select { max-width: 240px; }"),
                tags$style(type="text/css", ".span4 { max-width: 290px; }"),
                tags$style(type="text/css", ".well { max-width: 280px; }")
            ),
            h2('Filters/settings'),
            tags$br(),
            dateRangeInput("inv_trends_date_range", 
                label = "Date range",
                start = d$metadata$time_start, end = d$metadata$time_end),
            selectInput("inv_trends_frequency", label = "Bin width", 
                choices = list('month' = 'month', 'year' = 'year', 'week' = 'week', 'day' = 'day'), 
                selected = 'month'),
            radioButtons("inv_trends_breakout_by", 
                label = "Breakout variable",
                choices = list("-None-" = "NULL",
                               "Organization" = 'ticket_organization', 
                               "Category" = 'ticket_category',
                               "Cluster" = 'cluster'), 
                selected = "NULL"),
            checkboxGroupInput('inv_trends_subselect_show', 'Restrict to subgroups:',
                choices = c('Category', 'Organization')),
            conditionalPanel(
                condition = "input.inv_trends_subselect_show.indexOf('Category') > -1",
                uiOutput(outputId = "INV_trends_category_selection")
            ),
            conditionalPanel(
                condition = "input.inv_trends_subselect_show.indexOf('Organization') > -1",
                uiOutput(outputId = "INV_trends_dco_selection")
            )
        ),
        mainPanel(
            plotOutput("INV_trends", height = "700px")
        )
    )
)
