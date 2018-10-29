# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


#' @description Function to extract counts time series of desired breakdown and frequency:
#' @param time_variable The name (string) of the time column of interest
#' @param breakdown_variable The name (string) of a variable on which to split the series
#' @param frequency Controls the time resolution of the histogram bins
#' @param n_max_breakdown Working down from most frequent to least frequent subseries, 
#' compute no more than this many subseries
#' @param min_allocation Compute at most one subseries that makes up less than this fraction
#' of the total number of records
datatable2counts_time_series = function(
    time_variable, 
    breakdown_variable = NULL,
    frequency = c('month', 'year', 'week', 'day'), 
    n_max_breakdown = 10,
    min_allocation = 0.02){
    # Take notes as you go in the details list
    details = list()
    # Use a data.table:
    x = data.table(time = time_variable)
    if(!is.null(breakdown_variable)){
        stopifnot(length(time_variable) == length(breakdown_variable))
        x$bv = breakdown_variable
    }
    # Define the time bins:
    st = min(x$time)
    et = max(x$time)
    bins = seq(from = st, to = et, by = frequency[1])
    offset = et - max(bins)
    bins = c(st-1, bins + offset)
    details$bounds = c(bins[1], tail(bins, 1))
    # Create the series of binned counts for the total or broken down
    if(is.null(breakdown_variable)){
        counts = hist(x$time, breaks = bins, plot = FALSE)$counts
        series = matrix(counts, ncol = 1)
        colnames(series) = 'total'
    }else{
        setkey(x, bv)
        volumes = sort(table(x$bv), decreasing = TRUE)/nrow(x)
        n = min(length(volumes), n_max_breakdown, 1+sum(volumes > min_allocation))
        bv_levels = names(volumes)[1:n]
        series = matrix(NA, ncol = n, nrow = length(bins)-1)
        colnames(series) = bv_levels
        for(k in 1:n){
            xsub = subset(x, bv == bv_levels[k])
            series[,k] = hist(xsub$time, breaks = bins, plot = FALSE)$counts
        }
        details$n_bv_levels = length(volumes)
        details$inclusion_fraction = sum(series)/nrow(x)
    }
    out = list(series = series, details = details)
    return(out)
}

#' @description Plot one or more barplots positioned as a one-column array such that relative
#' bar heights both within and across barplots reflects the data, and the vertical axis
#' for each plot is no taller than it needs to be to allow all plots to be visually
#' separable.
#' @param series A matrix with one or more columns of numeric data; any column names
#' will be used to label the repective series in the plot.
multi_timeseries_barplot = function(series, details, shrinkage = 0.8){    
    n_excluded_groups = ifelse("n_bv_levels" %in% names(details), 
                               details$n_bv_levels - ncol(series),
                               0)
    st = format(details$bounds[1], '%Y-%m-%d')
    et = format(details$bounds[2], '%Y-%m-%d')
    maxes = apply(series, 2, max)
    allocations = maxes/sum(maxes)
    series = 0.9*series/sum(maxes)
    x_per_box = 1/nrow(series)
    x_left = seq(0, 1-x_per_box, by = x_per_box)
    x_right = x_left+x_per_box
    top_margin = 5*(n_excluded_groups > 0)
    par(xpd = TRUE, mar = c(5,0,top_margin,15))
    plot(x = 1, y = 1, xlim = c(0, 1), ylim = c(0,1), type = 'n', bty = 'n', 
         yaxt = 'n', xaxt = 'n', xlab = '', ylab = '')
    for(k in ncol(series):1){
        y_bottom = sum(allocations[1:k]) - allocations[k]
        y_top = y_bottom + series[,k] #pmin(, allocations[k])
        colors = rep('grey', nrow(series))
        colors[which(series[,k] > allocations[k])] = rgb(0, 0, 0, alpha = 0.3)
        rect(xleft = x_left, xright = x_right, ybottom = y_bottom, ytop = y_top,
             border = NA, col = colors)
        text(x = 1.01, y = y_bottom, labels = colnames(series)[k], adj = c(0,0))
    }
    # Include a reference line on the bar with maximum height
    whichmax = which(series == max(series), arr.ind = TRUE)
    whichmax = as.numeric(whichmax[nrow(whichmax),])
    maxvalue = as.numeric(maxes[whichmax[2]])
    scaled_max_value = as.numeric(series[whichmax[1], whichmax[2]])
    y_bottom = sum(allocations[1:whichmax[[2]]]) - allocations[whichmax[[2]]]
    y_position = y_bottom + scaled_max_value
    x_end = min(1.04, x_right[whichmax[1]] + 0.08)
    segments(x0 = x_left[whichmax[1]], x1 = x_end,
             y0 = y_position,          y1 = y_position,    lty = 2)
    text(x = x_end + 0.01, y = y_position - 0.01, adj = c(0, 0), 
         labels = paste0(maxvalue, " tickets (maximum)"), col = 'red', cex = 1.2)
    # Extra labels:
    text(x = c(0, 1)-0.02, y = -0.03, labels = c(st, et), srt = -45, adj = c(0, 0))
    if(ncol(series) > 1 && n_excluded_groups > 0){
        completeness_message = paste0("Excludes the least-observed ", 
                                      n_excluded_groups,
                                      " groups, \n which account for about ",
                                      round(100*(1-details$inclusion_fraction), 2),
                                      "% of the tickets:")
        text(x = 0.5, y = 1.12, adj = c(0.5, 0), cex = 1.3, labels = completeness_message)
    }
}