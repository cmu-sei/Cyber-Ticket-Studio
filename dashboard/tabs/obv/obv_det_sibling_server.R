# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

obv_siblings_table = function(input){
    table_maker = reactive({
        # Identify all computed similarities of observables with 
        #   the input$OBV_obs_select observable
        x = d$observable_similarities
        key = attributes(x)$key
        selected_obs = input$OBV_obs_select
        selected_clique = key[observable_value == selected_obs,]$clique 
        x = x[clique1 == selected_clique]
        x = x[,.(sim, clique2)]
        setnames(x, c('Similarity', 'clique'))
        setkey(x, clique)
        setkey(key, clique)
        x = merge(x, key)
        x$clique = NULL
        x = x[order(x$Similarity, decreasing = T),]
        setnames(x, c("Similarity","Sibling"))
        x = x[, .(Sibling, Similarity)]
        return(x)
    })
    
    DT::renderDataTable(
        table_maker(),
        options = list(
                lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
                pageLength = 10, 
                searching = FALSE,
                autoWidth = TRUE #
        ),
        rownames= FALSE
    )
}

obv_tickets = function(input){
  table_maker = reactive({
    selected_obs = d$observables[observable_value == input$OBV_obs_select,
                                 .(ticket_id,ticket_timestamp,ticket_organization,ticket_category)]
    #selected_obs = selected_obs[,!names(selected_obs) %in% c("observable_value","observable_type","cluster")]
    setnames(selected_obs, c("Ticket ID","Time reported", "Organization", "Category"))
    return(selected_obs)
  })
  DT::renderDataTable(
    table_maker(),
    options = list(
      lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
      pageLength = 10, 
      searching = FALSE,
      autoWidth = TRUE #
    ),
    rownames= FALSE
  )
}
output$OBV_SIBLINGS_table = obv_siblings_table(input)
output$INC_FOR_OBS = obv_tickets(input)

