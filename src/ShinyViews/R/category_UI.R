# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


make_category_view = function(id, d,
        panel_name = 'panel name',
        table_nsn= 'table',
        chart_nsn = 'chart',
        selected_category_nsn = 'select_category',
        category_label = 'category label',
        category_levels = c()){
    ns = NS(id)
    tabPanel(
        panel_name,
        tabsetPanel(
            tabPanel(
                "Table",
                column(12, dataTableOutput(ns(table_nsn)))
            ),
            ShinyViews::chart_by_subgroup_UI(id,
                                             chart_nsn = chart_nsn,
                                             group_nsn = selected_category_nsn,
                                             group_levels = category_levels,
                                             group_title = category_label
            )
        )
    )
}

### Some convenience wrappers for the function above
make_status_view = function(id, d){
    topic = 'Ticket status'
    view = make_category_view(id, d,
         panel_name = topic,
         table_nsn= 'table',
         chart_nsn = 'chart',
         selected_category_nsn = 'select_status',
         category_label = topic,
         category_levels = d$frequency_tables$organizations$Organization)
    return(view)
}
