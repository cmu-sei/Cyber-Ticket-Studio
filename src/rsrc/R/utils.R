# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

make_table = function(x, xname, freqname = 'Frequency'){
    tab = as.data.frame.table(table(x))
    tab[,1] = as.character(tab[,1])
    tab = tab[order(tab$Freq, decreasing = TRUE),]
    rownames(tab) = 1:nrow(tab)
    names(tab) = c(xname, freqname)
    return(tab)
}

#' Cleans free text for easier display of content
noteclean = function(text){
  print('converting text to utf-8')
  text = iconv(text, "latin1", "UTF-8")
  print('substituting hard return')
  text = gsub("\n", "<br/>", text)
  print('substitution extra-hard return')
  text = gsub("\\n", "<br/>", text)
  print('substitution of dod')
  text = gsub("[dot]", ".", text, fixed=T)
  print('substutition of period')
  text = gsub("[.]", ".", text, fixed=T)
  return(text)
}

fraction.to.pct = function (x, digits = 1){
    return(round(100 * x, digits))
}

freq.binner = function(freqs, bounds){
    freqs$freq = as.numeric(as.character(freqs$freq))
    freqs$count = as.numeric(as.character(freqs$count))
    freqs = data.table(freqs)
    setkey(freqs$count)
    nr = length(bounds)+1
    out = data.frame(label = rep(NA, nr), count = rep(NA, nr))
    out$label[1] = as.character(bounds[1])
    out$count[1] = sum(freqs$freq[freqs$count == bounds[1]])
    for(k in 2:length(bounds)){
        if(bounds[k] - bounds[k-1] > 1){
            out$label[k] = paste0(bounds[k-1]+1,'-', bounds[k])
            out$count[k] = sum(freqs$freq[(freqs$count > bounds[k-1])&
                                          (freqs$count <= bounds[k]) ])
        }else{
            out$label[k] = as.character(bounds[k])
            out$count[k] = sum(freqs$freq[ freqs$count == bounds[k] ])
        }
    }
    out$label[nr] = paste0('> ', bounds[nr-1])
    out$count[nr] = sum(freqs$freq[ freqs$count > bounds[k] ])
    return(out)
}

binned_frequency_table = function(x, bin.bounds){
    freqs = as.data.frame.table(table(table(x)))
    names(freqs) = c('count', 'freq')
    binned_freqs = freq.binner(freqs, bin.bounds)
    return(binned_freqs)
}

run.py.script = function(py_path, py_lib_path, script_path){
    python_main_path = paste0('export PATH="', py_path, ':$PATH"')
    python_modules_path = paste0('export PYTHONPATH="${PYTHONPATH}:', py_lib_path, '"')
    runscript = paste0('python ', script_path)
    command = paste0(python_main_path, "; ", python_modules_path, "; ", runscript)
    return(system(command, intern = TRUE))
}

max.pct = function(x, column){
    mytable = table(x[, column, with = FALSE])
    i.max = which.max(mytable)
    out = list()
    out$pct = as.numeric(fraction.to.pct(mytable[i.max]/nrow(x), digits = 0))
    out$best = names(mytable)[i.max]
    if(length(i.max) == 0) out = NULL
    return(out)
}

#' @description Remove rows of a data.table corresponding every value of a particular variable
#' for which there are fewer (or more than) lower (upper) rows
#' @param x A data.table
#' @param target The name of a column of x, must be an integer-valued column
#' @param lower An integer
#' @param upper An integer
integer.trim.by.count = function(x, target, lower = NULL, upper = NULL){
    stopifnot(is.data.table(x))
    stopifnot(is.numeric(unlist(x[,target, with = FALSE])))
    counts = table(x[,target, with = FALSE])
    bads = c()
    if(!is.null(lower)) bads = c(bads, as.numeric(names(counts)[counts < lower]) )
    if(!is.null(upper)) bads = c(bads, as.numeric(names(counts)[counts > upper]) )
    row.select = !is.element(unlist(x[,target, with = FALSE]), bads)
    return( x[row.select, ] )
}

#' Double the number of rows of the similarities matrix by including
#'   (b, a, sim) for each (a, b, sim) so that similarities containing
#'   a given clique can be found by scaning the first column
attach_reverse_clique_pairs = function(similarities){
    # To be able to use similarities as a lookup table (pick a doc; then
    #   find all related docs) without re-sorting each time, we need to include
    #   the reverse similarity:
    key = attributes(similarities)$key
    temp = copy(similarities)
    setnames(temp, c('clique2', 'count2'), c('clique_temp', 'count_temp'))
    setnames(temp, c('clique1', 'count1'), c('clique2', 'count2'))
    setnames(temp, c('clique_temp', 'count_temp'), c('clique1', 'count1'))
    similarities = rbind(similarities, temp)
    if(!is.null(key)) attributes(similarities)$key = key
    return(similarities)
}
