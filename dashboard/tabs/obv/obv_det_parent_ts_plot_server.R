# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

# Trends plot
output$OBV_trends = renderPlot({
  x = d$observables
  date_range = as.POSIXct(input$obv_trends_date_range)
  x = x[x$ticket_timestamp >= date_range[1], ]
  x = x[x$ticket_timestamp <= date_range[2], ]   
  if('Category' %in% input$obv_trends_subselect_show){
    setkey(x, ticket_category)
    x = x[ticket_category %in% input$obv_trends_category_selection, ]
  }
  if('Organization' %in% input$obv_trends_subselect_show){
    setkey(x, ticket_category)
    x = x[ticket_organization %in% input$obv_trends_dco_selection, ]        
  }
  bv = input$obv_trends_breakout_by
  if(bv == "NULL"){
    bv = NULL
  }else{
    bv = x[[bv]]
  }
  series_and_details = datatable2counts_time_series(
    time_variable = x$ticket_timestamp, 
    breakdown_variable = bv,
    frequency = input$obv_trends_frequency)
  multi_timeseries_barplot(
    series = series_and_details$series,
    details = series_and_details$details,
    shrinkage = input$inv_trends_breakout_shrinkage)
  #if(length(input$inv_trends_subselect_show) > 0) browser()
})
