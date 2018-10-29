# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

obv_det_subview = tabPanel(
    "Details", 
    br(),
    textInput('OBV_obs_select', 
        label='Enter an observable:',
        value=d$frequency_tables$obs$Observable[1]),   #
    tabsetPanel(
        tabPanel(
            "Seen in tickets (trend)", 
            br(),
            
            sidebarLayout(
              sidebarPanel(
                h2('Filters/settings'),
                tags$br(),
                dateRangeInput("obv_trends_date_range", 
                               label = "Date range",
                               start = d$metadata$time_start, end = d$metadata$time_end),
                selectInput("obv_trends_frequency", label = "Bin width", 
                            choices = list('month' = 'month', 'year' = 'year', 'week' = 'week', 'day' = 'day'), 
                            selected = 'month'),
                radioButtons("obv_trends_breakout_by", 
                             label = "Breakout variable",
                             choices = list("-None-" = "NULL",
                                            "Organization" = "ticket_organization",
                                            "Category" = 'ticket_category'), 
                             selected = "NULL"),
                conditionalPanel(
                  condition = "input.obv_trends_subselect_show.indexOf('Category') > -1",
                  uiOutput(outputId = "OBV_trends_category_selection")
                ),
                conditionalPanel(
                  condition = "input.obv_trends_subselect_show.indexOf('Organization') > -1",
                  uiOutput(outputId = "OBV_trends_dco_selection")
                )
              ),
              mainPanel(
                plotOutput("OBV_trends", height = "700px")
              )
            )
            
        ),
        tabPanel(
          "Seen in tickets (table)", 
          br(),
          p('Each observable is seen (mentioned) in one or more tickets.  The table below 
            shows tickets that mentioned the selected obervable.'),
          dataTableOutput('INC_FOR_OBS')
        ),
        tabPanel(
            "Co-mentioned observables",
            br(),
            p('Two observables are similar if the two sets of tickets that contain them are similar:'),
            dataTableOutput('OBV_SIBLINGS_table')
        )
    ) #tabsetPanel 
) #tabPanel
