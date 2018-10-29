# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


source('tabs/inv/det/inv_det_related_ui.R')
inv_det_subview = tabPanel(
    "Details", 
    br(),
    textInput('INV_ticket_select', 
            label='Enter a ticket ID:',
            value=d$frequency_tables$tickets$ticket[1]),
    tabsetPanel(
        tabPanel(
            "Notes and worklogs",
            br(),
            htmlOutput("INV_notes"),
            htmlOutput("INV_worklogs")
        ),
        tabPanel(
            "Mentioned observables",
            br(),
            dataTableOutput("INV_child_table")
        ),
        inv_det_related_subview
    )
)