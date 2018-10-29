# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

obv_tbl_subview = tabPanel(
    "Table",
    sidebarLayout(
        sidebarPanel(
            h2('Filters'),
            tags$br(),
            textInput('OBV_regex', 
                label='Match this regex:',
                value= '*'),
            selectInput('OBV_organization', 
                label = "Select organization:",
                choices = c('- all organizations -', d$frequency_tables$organizations$Organization), 
                selected = '- all organizations -'),
            selectInput('OBV_obs_type', 
                label = "Select observable type:",
                choices = c('- all types -', 
                            d$frequency_tables$observable_types[,'Observable type']), 
                selected = '- all types -')                    
        ),
        mainPanel(
            dataTableOutput('OBV_table')
        )
    )
)
