# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


shinyServer(function(input, output, session){
    i = input
    o = output
    s = session
    ### tickets _view (INV) ###
    source('tabs/inv_server.R', local = TRUE)

    ### observables_view (OBV) ###
    source('tabs/obv_server.R', local = TRUE)

    ### observables_view (OBV) ###
    source('tabs/cmv_server.R', local = TRUE)

    ### organization_view ###
    output$'organization_view-org_table' = ShinyViews::render_table(i,o,s, d$frequency_tables$organizations)
    output$'organization_view-chart_ts' = callModule(ShinyViews::ticket_trends_per_group, 'organization_view',
                    DT = d$tickets, input_name = 'organization_name')
})
