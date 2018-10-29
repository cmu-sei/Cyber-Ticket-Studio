# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


#' @description
#' @param id namespace
#' @param chart_nsn (string) namespace name of the chart to display
#' @param group_nsn (string) namespace name of the group value that the user selects in this UI
chart_by_subgroup_UI = function(id, chart_nsn, group_nsn, group_levels = c(),
                                group_title = 'title', group_default = "-- All --"){
    ns = NS(id)
    panel = tabPanel(
        "Trends",
        sidebarLayout(
            sidebarPanel(
                selectInput(ns(group_nsn), group_title,
                            choices = c(group_default, group_levels),
                            multiple=FALSE, selectize=TRUE, selected=1),
                # checkboxInput("agtrends_noop", "Limit to tickets assigned outside of operations?",
                #               value=FALSE),
                width = 3
            ),
            mainPanel(
                showOutput(ns(chart_nsn), "highcharts")
            )
        )
    )
    return(panel)
}


