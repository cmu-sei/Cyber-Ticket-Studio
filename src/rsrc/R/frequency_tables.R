# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


make_frequency_tables = function(D){
    print('counting tickets and distinct observables per ticket_organization')
    setkey(D$tickets, ticket_id)
    setkey(D$observables, ticket_id)
    joined = merge(D$tickets[,.(ticket_id, ticket_organization)],
                   D$observables[,.(ticket_id, observable_value)])
    stopifnot(nrow(joined) == nrow(D$observables))
    joined$ticket_id = NULL
    joined = joined[order(ticket_organization, observable_value)]
    stopifnot(is.null(key(joined)))
    joined = unique(joined)
    organizations_table = make_table(D$tickets$ticket_organization, 'Organization', freqname = '# of tickets')
    temp = make_table(joined$ticket_organization, 'Organization', freqname = '# of uniq. observables')
    organizations_table = merge(organizations_table, temp, all.x = TRUE)
    organizations_table = organizations_table[order(organizations_table[,'# of tickets'], decreasing = T),]
    
    # print('counting occurances of each observable in APT notes and blacklists')
    # indicators = data.table(dbGetQuery(conn=db, "SELECT * from indicators"))
    # # blacklists per observable
    # blacklists = indicators[source_type == 'blacklist', .N ,by = observable_value]
    # names(blacklists) = c("Observable", "blacklist_count")
    # # APT notes per observable
    # apt_notes = indicators[source_type == 'APT notes', .N ,by = observable_value]
    # names(apt_notes) = c("Observable", "APT_count")
    # 
    print('building obs table: counts of tickets per observable')
    setkey(D$observables, ticket_organization)
    obs_count_table = make_table(D$observables$observable_value, 'Observable', '# of tickets')
    obs_count_table = data.table(obs_count_table)
    #obs_count_table = merge(obs_count_table, blacklists, by = 'Observable', all.x = TRUE)
    #obs_count_table = merge(obs_count_table, apt_notes, by = 'Observable', all.x = TRUE)
    #obs_count_table$blacklist_count[is.na(obs_count_table$blacklist_count)] = 0
    #obs_count_table$APT_count[is.na(obs_count_table$APT_count)] = 0
    #obs_count_table[,sum:=APT_count + blacklist_count]
    #setorder(obs_count_table, -sum)
    #obs_count_table[,sum:=NULL]
    
    print('building tickets table: counts of observables per ticket')
    ticket_count_table = make_table(D$observables$ticket_id, 'ticket', '# of observables')
    
    print('building observable types table: counts of observables per observable type')
    obs_type_counts = make_table(D$observables$observable_type, 'Observable type', '# of observables')
    
    print('building categories table: counts of tickets per ticket_category')
    ticket_category_counts = make_table(D$tickets$ticket_category, 'Category', '# of tickets')
    
    print('building tables of the distributions of ticket & observable cluster sizes')
    TT = rsrc::summarize_cluster_sizes(D$ticket_clusters$clust_doc_map)
    OO = rsrc::summarize_cluster_sizes(D$observable_clusters$clust_doc_map)
    frequency_tables = list(
        organizations = organizations_table
        ,obs = obs_count_table
        #,blacklists = blacklists
        #,apt_notes = apt_notes
        ,tickets = ticket_count_table
        ,ticket_cluster_sizes = TT
        ,observable_cluster_sizes = OO
        ,observable_types = obs_type_counts
        ,categories = ticket_category_counts
    )
    return(frequency_tables)
}
