# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


#' utility for entering edges into an igraph
columns2edges = function(col1, col2) as.numeric(rbind(col1, col2))
#stopifnot(columns2edges(c(1,2,3), c(4,5,6)) == c(1,4, 2,5, 3,6))

#' Uses a sparse matrix of similarities to create a weighted adjacency graph and then
#' applies the fastgreedy algorithm to identify clusters of nodes
#' 
#' @param sims A data.table with three columns: clique1, clique2, sim.  clique1 and clique2
#' are indices on the nodes
cluster = function(sims){
    print('Creating the igraph of similarities ...')
    n_vertices = max(c(sims$clique1, sims$clique2))
    igr = igraph::graph.empty(directed=F)
    igr = igraph::add_vertices(igr, nv = n_vertices )
    igr = igraph::add_edges(igr, 
                    edges = columns2edges(sims$clique1, sims$clique2), 
                    weight = sims$sim) 
    print('Clustering with igraph::cluster_fast_greedy ...')
    igrclust = igraph::cluster_fast_greedy(igr)
    
    clust_ids = as.numeric(as.character(igraph::membership(igrclust))) 
    clique_clust = data.table::data.table(clique = 1:n_vertices, cluster = clust_ids)
    return(clique_clust) #clusters = cluster_walktrap(sim.igr)
}

#' Translate the clique clusters into their underlying doc clusters
rekey = function(key, clique_clusters){
    key = merge(key, clique_clusters, by = 'clique')
    key$clique = NULL
    # Remove any clique clusters that correspond to a single doc
    key = integer.trim.by.count(key, target = "cluster", lower = 2)
    # Re-index the clusters to be 1:n_clusters
    clust_idx = sort(unique(key$cluster))
    relabeler = data.table(clustnew = 1:length(clust_idx), cluster = clust_idx)
    key = merge(key, relabeler, by = 'cluster')
    key$cluster = key$clustnew
    key$clustnew = NULL
    clique_clusters = merge(clique_clusters, relabeler, by = 'cluster')
    clique_clusters$cluster = clique_clusters$clustnew
    clique_clusters$clustnew = NULL
    return(list(clust_doc_map = key, clust_clique_map = clique_clusters))
}

summarize_clusters = function(items, item_clusters, kind){
    stopifnot(kind %in% c("ticket", "observable"))
    n = max(item_clusters$clust_clique_map$cluster)
    nas = rep(NA, n)
    pb = txtProgressBar(min = 1, max = n, style = 3)
    summaries = data.frame('k' = 1:n, 
                           'num.tickets' = nas,
                           'max.cat' = nas,
                           'pct.max.cat' = nas,
                           'max.agcy' = nas,
                           'pct.max.agcy' = nas,
                           'max.type' = nas,
                           'pct.max.type' = nas,
                           'peak.time' = nas,
                           'most.recent' = nas)
    
    setkey(items, cluster)
    for(k in 1:n){
        setTxtProgressBar(pb, k)
        kth.clust = items[cluster == k,]
        # items-level metrics:
        main = max.pct(kth.clust, 'ticket_category')
        if(!is.null(main)){
            summaries[k, 'max.cat'] = main$best
            summaries[k, 'pct.max.cat'] = main$pct
        }
        main = max.pct(kth.clust, 'ticket_organization')
        summaries[k, 'max.agcy'] = main$best
        summaries[k, 'pct.max.agcy'] = main$pct
        if(kind == "observable"){
            main = max.pct(kth.clust, 'observable_type')
            summaries[k, 'max.type'] = main$best
            summaries[k, 'pct.max.type'] = main$pct
        }
        # tickets-level metrics:
        setkey(kth.clust, ticket_id)
        kth.clust = unique(kth.clust)
        summaries[k, 'num.tickets'] = nrow(kth.clust)
        time.lag = difftime(Sys.time(), kth.clust$ticket_timestamp, 
                            units = 'days')
        time.lag = na.omit(as.numeric(time.lag))
        x = density(time.lag, bw = 10)
        summaries[k, 'peak.time'] = round(x$x[which.max(x$y)], 1)
        summaries[k, 'most.recent'] = round(min(time.lag), 1)
    }
    close(pb)
    
    summaries = data.table(summaries)
    setorder(summaries, -num.tickets)
    summaries$k = 1:nrow(summaries)
    setnames(summaries, 
         c('cluster id', '# of tickets', 'Top category', '% category', 
           'Top organization', '% organization', 'Top type', '% type', 'Peak time', 
           'Most recent'))
    summaries = summaries[, 
        c('cluster id', '# of tickets', 'Peak time', 'Most recent', 
          'Top organization', '% organization', 'Top type', '% type', 'Top category', 
          '% category'), with = FALSE]
    return(summaries)
}

summarize_cluster_sizes = function(clust_doc_map){
    com_sizes = table(clust_doc_map$cluster)
    com_sizes = as.data.frame.table(table(com_sizes))
    names(com_sizes) = c('count', 'freq')
    com_sizes = freq.binner(com_sizes, c(2,15,50))
    com_sizes$count = as.character(com_sizes$count)
    names(com_sizes) = c("Cluster size", "Frequency")
    return(com_sizes)
}

# summarize_ticket_clusters = function(tickets, ticket_clusters){
#     n = max(ticket_clusters$clust_clique_map$cluster)
#     nas = rep(NA, n)
#     summaries = data.frame('k' = 1:n, 
#                            'num.tickets' = nas,
#                            'max.cat' = nas,
#                            'pct.max.cat' = nas,
#                            'max.agcy' = nas,
#                            'pct.max.agcy' = nas,
#                            'peak.time' = nas,
#                            'most.recent' = nas)
#     
#     setkey(tickets, cluster)
#     pb = utils::txtProgressBar(min = 1, max = n, style = 3)
#     for(k in 1:n){
#         setTxtProgressBar(pb, k)
#         kth.clust = tickets[cluster == k,]
#         main = max.pct(kth.clust, 'ticket_category')
#         if(!is.null(main)){
#             summaries[k, 'max.cat'] = main$best
#             summaries[k, 'pct.max.cat'] = main$pct
#         }
#         main = max.pct(kth.clust, 'ticket_organization')
#         summaries[k, 'max.agcy'] = main$best
#         summaries[k, 'pct.max.agcy'] = main$pct
#         summaries[k, 'num.tickets'] = nrow(kth.clust)
#         time.lag = difftime(Sys.time(), kth.clust$ticket_timestamp, 
#                             units = 'days')
#         time.lag = na.omit(as.numeric(time.lag))
#         if(length(time.lag)>0){
#             x = density(time.lag, bw = 10)
#             summaries[k, 'peak.time'] = round(x$x[which.max(x$y)], 1)
#             summaries[k, 'most.recent'] = round(min(time.lag), 1)
#         }
#     }
#     close(pb)
#     
#     summaries = summaries[summaries$num.tickets > 1,]
#     summaries = data.table(summaries) #backup = summaries
#     setorder(summaries, -num.tickets)
#     setnames(summaries, 
#              c('cluster id', '# of tickets', 'Top category', '% category', 
#                'Top organization', '% organization', 'Peak time', 'Most recent'))
#     summaries = summaries[, 
#                           c('cluster id', '# of tickets', 'Peak time', 'Most recent', 
#                             'Top organization', '% organization', 'Top category', '% category'), with = FALSE]
#     return(summaries)
# }
# 
# summarize_observable_clusters = function(observables, observable_clusters){
#     n = max(observable_clusters$clust_clique_map$cluster)
#     nas = rep(NA, n)
#     pb = txtProgressBar(min = 1, max = n, style = 3)
#     summaries = data.frame('k' = 1:n, 
#                            'num.tickets' = nas,
#                            'max.cat' = nas,
#                            'pct.max.cat' = nas,
#                            'max.agcy' = nas,
#                            'pct.max.agcy' = nas,
#                            'max.type' = nas,
#                            'pct.max.type' = nas,
#                            'peak.time' = nas,
#                            'most.recent' = nas)
#     
#     setkey(observables, cluster)
#     for(k in 1:n){
#         setTxtProgressBar(pb, k)
#         kth.clust = observables[cluster == k,]
#         # observables-level metrics:
#         main = max.pct(kth.clust, 'ticket_category')
#         if(!is.null(main)){
#             summaries[k, 'max.cat'] = main$best
#             summaries[k, 'pct.max.cat'] = main$pct
#         }
#         main = max.pct(kth.clust, 'ticket_organization')
#         summaries[k, 'max.agcy'] = main$best
#         summaries[k, 'pct.max.agcy'] = main$pct
#         main = max.pct(kth.clust, 'observable_type')
#         summaries[k, 'max.type'] = main$best
#         summaries[k, 'pct.max.type'] = main$pct
#         # tickets-level metrics:
#         setkey(kth.clust, ticket_id)
#         kth.clust = unique(kth.clust)
#         summaries[k, 'num.tickets'] = nrow(kth.clust)
#         time.lag = difftime(Sys.time(), kth.clust$ticket_timestamp, 
#                             units = 'days')
#         time.lag = na.omit(as.numeric(time.lag))
#         x = density(time.lag, bw = 10)
#         summaries[k, 'peak.time'] = round(x$x[which.max(x$y)], 1)
#         summaries[k, 'most.recent'] = round(min(time.lag), 1)
#     }
#     close(pb)
#     
#     summaries = data.table(summaries)
#     setorder(summaries, -num.tickets)
#     summaries$k = 1:nrow(summaries)
#     setnames(summaries, 
#              c('cluster id', '# of tickets', 'Top category', '% category', 
#                'Top organization', '% organization', 'Top type', '% type', 'Peak time', 
#                'Most recent'))
#     summaries = summaries[, 
#                           c('cluster id', '# of tickets', 'Peak time', 'Most recent', 
#                             'Top organization', '% organization', 'Top type', '% type', 'Top category', 
#                             '% category'), with = FALSE]
#     return(summaries)
# }
