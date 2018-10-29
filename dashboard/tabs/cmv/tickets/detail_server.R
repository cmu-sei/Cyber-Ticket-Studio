# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


# Cluster detail:
inner_table_maker = reactive({ 
    setkey(d$tickets, cluster)
    cluster = d$tickets[cluster == input$CMV_ticket_cluster_index,]
    cluster$cluster = NULL
    cluster$ticket_notes = NULL
    cluster = cluster[order(cluster$ticket_timestamp, decreasing = TRUE),]
    
    date_range = as.POSIXct(input$cmv_ticket_cluster_date_range)
    cluster = cluster[cluster$ticket_timestamp >= date_range[1], ]
    cluster = cluster[cluster$ticket_timestamp <= date_range[2], ]    
    
    s = input$CMV_ticket_summaries_rows_selected
    if(length(s)){ 
        updateTextInput(session, 'CMV_ticket_cluster_index', value = s)
    }
    return(cluster)
})

table_maker = function(input){
    DT::renderDataTable(
        inner_table_maker(),
        selection = list(mode='single'),
        options = list(
            lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
            pageLength = 10, 
            searching = FALSE,
            autoWidth = TRUE #
        ),
        rownames = FALSE,
        server = TRUE
    )
}
output$CMV_ticket_cluster_det = table_maker(input)

output$CMV_ticket_breakout_over_time = renderPlot({
    x = inner_table_maker()
    bv = input$cmv_ticket_detail_breakoutby
    if(bv == "NULL"){
        bv = NULL
    }else{
        bv = x[[bv]]
    }
    series_and_details = datatable2counts_time_series(
        time_variable = x$ticket_timestamp, 
        breakdown_variable = bv)
    multi_timeseries_barplot(
        series = series_and_details$series,
        details = series_and_details$details,
        shrinkage = input$cvm_ticket_detail_breakout_shrinkage)
})

