# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


dbtable2DT = function(conn, table_name){
    query = paste0('SELECT * FROM ', table_name)
    return(data.table(DBI::dbGetQuery(conn=conn, query)))
}

load_tickets = function(conn){
    print('Loading the tickets table from the db')
    tickets = dbtable2DT(conn, 'tickets')
    print('Convert ticket_timestamp to R time format')
    tickets[, ticket_timestamp := as.POSIXct(tickets$ticket_timestamp)]
    return(tickets)
}

load_similarities = function(conn, kind){
    stopifnot(kind %in% c("ticket", "observable"))
    S = dbtable2DT(conn, paste0(kind, '_similarities'))
    CM = dbtable2DT(conn, paste0(kind, '_cliques'))
    # Use indexing from 1 instead of zero for compatibility with R-igraph:
    S$clique1 = 1 + S$clique1
    S$clique2 = 1 + S$clique2
    S$sim = round(S$sim, 3)
    CM$clique = 1 + CM$clique
    # Remove clique labels from all perfectly isolated docs
    cliques = unique(c( S$clique1 , S$clique2 ))
    CM = CM[is.element(clique, cliques),]
    attributes(S)$key = CM
    if(kind == "ticket"){
        setnames(attributes(S)$key, "doc", "ticket_id")
    }else{
        setnames(attributes(S)$key, "doc", "observable_value")
    }
    return(S)
}

load_observables = function(conn){
    ## This makes an indexed observables table 
    #   so that cyber_ticket_studio can do fast lookup of which tickets contain a given
    #   observable, and vice-versa
    print('loading the observables table from the db, joining with some columns of tickets')
    query = paste0(
        "SELECT tickets.ticket_timestamp, tickets.ticket_organization, tickets.ticket_category"
        ,", observables.*"
        ," FROM tickets"
        ," JOIN observables on tickets.ticket_id = observables.ticket_id"
    )
    observables = data.table(dbGetQuery(conn=conn, query))
    observables[,ticket_timestamp := as.POSIXct(observables$ticket_timestamp)]
    return(observables)
}

