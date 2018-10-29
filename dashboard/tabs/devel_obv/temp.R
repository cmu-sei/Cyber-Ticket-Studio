# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

            actionButton("ind_updateID", "Go (change ID)"),
            radioButtons("ticket_selectplotcode", "Color plotted tickets by:", 
                c("Organization", "Category", "Assigned Group"), 
                selected = "Organization"),
            showOutput("ticket_indplot_tip", "highcharts"),
            
output$ticket_indplot_tip <- renderChart2({
    
    data = getIndTS()
    getPlotType()
      
    isolate({
    setkey(data, ticket_id)
    setkey(tickets, ticket_id)
    data = tickets[data]
    
    setkey(data, ticket_timestamp)
    data$cdf = 1:nrow(data)
    data$x = data$ticket_timestamp
    data$y = data$cdf
    data$x = as.numeric(data$x)
    data$x = data$x*1000
    data$ticket_timestamp = as.character(data$ticket_timestamp)
    data$resolved = as.character(data$resolved)
    data$index = 1:nrow(data)
    
    p1 =  rCharts:::Highcharts$new()
    p1$title(text=paste(indsum[ticket_id==input$ticket_indplot_choose,value], " (",indsum[ticket_id==input$ticket_indplot_choose,type] , ")"))
    p1$chart(zoomType="x")
    count = 1
    p1$yAxis(min=0)

    if(input$ticket_selectplotcode == "Organization"){
      for(ag in unique(data$dco)){
        p1$series(data = toJSONArray2(data[dco==ag], json=F), type="scatter", 
                  name=ag, color=coldict[count%%length(coldict)],
                  pointInterval = 24*3600*1000)
        count = count+1
      }  
    }else if(input$ticket_selectplotcode == "Category"){
      for(ag in unique(data$catsubcat)){
        p1$series(data = toJSONArray2(data[catsubcat==ag], json=F), type="scatter", 
                  name=ag, color=coldict[count%%length(coldict)],
                  pointInterval = 24*3600*1000)
        count = count+1
      }  
    }else{
      for(ag in unique(data$assignedgroup)){
        p1$series(data = toJSONArray2(data[assignedgroup==ag], json=F), type="scatter", 
                  name=ag, color=coldict[count%%length(coldict)],
                  pointInterval = 24*3600*1000)
        count = count+1
      }  
    }

    p1$xAxis(type="datetime")
    
    p1$tooltip( formatter = 
                  "#! function() { 
                return (this.point.index + '<br>' + this.point.name + '<br>' + 
                        'reported: ' + this.point.reported + '<br>' +
                        '  resolved: ' + this.point.resolved + '<br>' +
                        this.point.id + '<br>' +
                        this.point.catsubcat + '<br>' +
                        this.point.assignedgroup  
                );}
                !#")
    return(p1)
    })
    
  })
