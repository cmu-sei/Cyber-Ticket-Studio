# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


#' @description Given a ticket id, return a new copy of the tickets table with a 
#' JaccardSim column for the Jaccard similarity between each ticket and the given ticket
get_tickets_by_ticket = function(id){
    x = d$ticket_similarities
    key = attributes(x)$key
    selected_clique = key[ticket_id == id,]$clique
    x = x[clique1 == selected_clique, .(clique2, sim, count1, count2)]
    setnames(x, 'clique2', 'clique')
    #     if(length(selected_clique) > 0){
    #         x = rbind(data.table(clique = selected_clique, sim = c(1)), x)
    #     }
    setkey(x, clique)
    setkey(key, clique)
    x = merge(x, key)
    x$clique = NULL
    y = d$tickets[, .(ticket_id, ticket_timestamp, ticket_organization, ticket_category)]
    setnames(y, c('Ticket', 'Timestamp', 'Organization', 'Category'))
    setnames(x, c('sim', 'ticket_id'), c('JaccardSim', 'Ticket'))
    y = merge(y, x, by = "Ticket", all.x = TRUE)
    setnames(y, c('count1', 'count2'), c('c1', 'c2'))
    y = y[is.na(get("JaccardSim")), ("JaccardSim") := 0]
    y = y[is.na(get("c1")), ("c1") := 0]
    y = y[is.na(get("c2")), ("c2") := 0]
    return(y)
}

inv_related_table = function(input){
    table_maker = reactive({
        id = input$INV_ticket_select
        y = get_tickets_by_ticket(id)
        ticket_dt = y[Ticket==id]
        #y = y[Ticket!=id]
        #y$JaccardSim[y$Ticket==id] = 1
        timeSim = difftime(y$Timestamp, ticket_dt$Timestamp[1], units = 'days')
        timeSim = exp(-abs(as.numeric(timeSim))/30)
        organizationSim = 0 + (y$Organization == ticket_dt$Organization[1])
        categorySim = 0 + (y$Category == ticket_dt$Category[1])
        count_multiplier = 1
        if(input$sim_use_jaccard_counts){
            count_multiplier = 0.25*sqrt(y$c1*y$c2)
        }
        y$GlobalSim = round((y$JaccardSim*input$sim_jaccard_coeff*count_multiplier + 
                            timeSim*input$sim_time_coeff + 
                            organizationSim*input$sim_organization_coeff +
                            categorySim*input$sim_category_coeff
                            ), 2)
        y$JaccardSim = round(y$JaccardSim,2)
        y = y[order(y$GlobalSim, decreasing = T),]
        y$Timestamp = format(round(y$Timestamp, units="hours"), '%Y-%m-%d %H')
        # Force the target ticket to the top:
        ticket_dt = y[Ticket==id]
        y = y[Ticket!=id]
        y = rbind(ticket_dt, y)
        y$JaccardSim[1] = NA
        y$GlobalSim[1] = NA
        # Stop lying about counts, which may be nonzero if we did not observe it
        y = y[get("c2")==0, ("c2") := NA]
        # Don't display the observables count of the target ticket; that's on another tab
        y$c1 = NULL
        setnames(y, 'c2', 'Obs Count') #
        return(y)
    })
    
    DT::renderDataTable(
        table_maker(),
        options = list(
                lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
                pageLength = 10, 
                searching = FALSE,
                autoWidth = TRUE #
        ),
        rownames= FALSE,
        server = TRUE
    )
}
output$INV_RELATED_table = inv_related_table(input)

