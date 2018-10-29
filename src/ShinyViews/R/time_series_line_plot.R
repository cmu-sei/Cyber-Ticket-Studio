# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

#' @description Implements default preferences for how to display a table
#' @param DT (data.table)
ticket_trends_per_group = function(input, output, session, DT, input_name, variable_name){
    trends_reactive = reactive({
        group_name = input[[input_name]]
        if(group_name=="-- All --"){
            dt = DT
        }else{
            dt = DT[DT[,variable_name]==group_name,]
        }
        # if(input$'mtslct-agtrends_noop'){
        #     d = d[assignedgroup!="Operations"]
        # }
        return(list(
            n_new  = rsrc::reformat_for_rCharts(rsrc::n_new_daily(dt)),
            n_open = rsrc::reformat_for_rCharts(rsrc::n_open_EOD(dt))
        ))
    })
    charter = reactive({
        seconds_per_day = 24*3600
        trends = trends_reactive()
        p1 = rCharts:::Highcharts$new()
        p1$chart(zoomType="x")
        p1$series(data = rCharts::toJSONArray2(trends$n_new, json=F),
                  name="Number of tickets reported per day", pointInterval = seconds_per_day*1000)
        # p1$series(data = rCharts::toJSONArray2(trends$n_open, json=F),
        #           name="Open tickets (end-of-day)", pointInterval = seconds_per_day*1000)
        p1$xAxis(type="datetime")
        p1$yAxis(min=0)
        p1$plotOptions(series=list(turboThreshold = 5000))
        return(p1)
    })
    return(renderChart2({charter()}))
}

