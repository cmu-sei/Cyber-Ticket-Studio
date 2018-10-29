# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

#' @description Given something like a time series, fill in the value for  any missing days 
#' (or other time unit) with the value from the previous non-missing day
#' @param dt data.table with index %in% colnames(dt)
#' @param index The name of the indexing variable
#' @param by Used with seq to generate the full series with no missing values
lag_fill_by_index = function(dt, index = 'day', by = 'day'){
    if(nrow(dt) == 0) return(dt)
    setkeyv(dt, index)
    index_values = dt[[index]]
    all_values = seq(index_values[1], last(index_values), by)
    return(dt[J(all_values), roll=Inf])
}

#' @description Create a data.table with the number of tickets open at the end of each day 
n_open_EOD = function(d){
    stopifnot(nrow(d)>0)
    dt = data.table("date"=c(d$ticket_timestamp, d$resolved), 
                    "change"=rep(c(1,-1), each = nrow(d)) )
    setkey(dt, "date")
    dt = dt[!is.na(date),]
    dt[,count:=cumsum(change)] # count = cumulative number of tickets open, accounting for closures
    dt[,day:=as.Date(dt$date)]
    dt = dt[, .(day, count)]
    # Keep only the last row in each day, reflecting number of tickets open at end-of-day
    dt = dt[, .SD[.N], by=day]
    # Fill any missing days with the count from the previous non-missing day
    return(lag_fill_by_index(dt))
}

#' @description Create a data.table with the number of tickets opened each day
n_new_daily = function(dt){
    dt[,day:=as.Date(dt$ticket_timestamp)]
    dt = dt[,.(day)]
    dt = dt[,.(count=.N), by=day]
    return(lag_fill_by_index(dt))
}

#' @description Rescale the time column ('day') to be in milliseconds instead of days
reformat_for_rCharts = function(dt){
    seconds_per_day = 24*3600
    milliseconds_per_second = 1000
    setnames(dt, c("day", "count"), c("x", "y"))
    dt$x = as.numeric(dt$x)*seconds_per_day*milliseconds_per_second
    return(dt)
}