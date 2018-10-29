# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

make_organization_view = function(id, d,
        panel_name = 'Organizations',
        org_table_name = 'org_table',
        ts_chart_name = 'chart_ts',
        ts_select_name = 'organization_name'){
    ns = NS(id)
    tabPanel(
        panel_name,
        tabsetPanel(
            tabPanel(
                "Table",
                column(12, dataTableOutput(ns(org_table_name)))
            ),
            ShinyViews::chart_by_subgroup_UI(id,
                chart_nsn = ts_chart_name,
                group_nsn = ts_select_name,
                group_levels = d$frequency_tables$organizations$Organization,
                group_title = 'Organization'
            )
        )
    )
}
