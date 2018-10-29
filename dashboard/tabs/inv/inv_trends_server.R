# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


# Category
output$INV_trends_category_selection = renderUI({
    checkboxGroupInput(
    "inv_trends_category_selection", "Select categories:",
    choices = unique(d$tickets$ticket_category),
    selected = "Lost device")
})

# DCO
output$INV_trends_dco_selection = renderUI({checkboxGroupInput(
    "inv_trends_dco_selection", "Select some organizations:",
    choices = unique(d$tickets$ticket_organization),
    selected = "Ministry of Peace")
})

# Trends plot
output$INV_trends = renderPlot({
    x = d$tickets
    date_range = as.POSIXct(input$inv_trends_date_range)
    x = x[x$ticket_timestamp >= date_range[1], ]
    x = x[x$ticket_timestamp <= date_range[2], ]   
    if('Category' %in% input$inv_trends_subselect_show){
        setkey(x, ticket_category)
        x = x[ticket_category %in% input$inv_trends_category_selection, ]
    }
    if('Organization' %in% input$inv_trends_subselect_show){
        setkey(x, ticket_category)
        x = x[ticket_organization %in% input$inv_trends_dco_selection, ]        
    }
    bv = input$inv_trends_breakout_by
    if(bv == "NULL"){
        bv = NULL
    }else{
        bv = x[[bv]]
    }
    #if(nrow(x)  == 0) browser()
    shiny::req(nrow(x) > 0)
    series_and_details = rsrc::datatable2counts_time_series(
        time_variable = x$ticket_timestamp, 
        breakdown_variable = bv,
        frequency = input$inv_trends_frequency)
    rsrc::multi_timeseries_barplot(
        series = series_and_details$series,
        details = series_and_details$details)
})
