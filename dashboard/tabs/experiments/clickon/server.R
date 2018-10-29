# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

library(shiny)
library(rCharts)

shinyServer(function(input, output) {
  
  output$text <- renderText({
    sprintf("The capital of %s is %s.", input$click$country, input$click$capital)
  })
  
  output$chart <- renderChart({
    a <- Highcharts$new()
    a$series(data = list(
        list(x = 0, y = 40, capital = "Stockholm", country = "Sweden"),
        list(x = 1, y = 50, capital = "Copenhagen", country = "Denmark"),
        list(x = 2, y = 60, capital = "Oslo", country = "Norway")
      ), type = "bar"
    )
    a$xAxis(categories = c("Sweden", "Denmark", "Norway"))
    a$plotOptions(
      bar = list(
        cursor = "pointer", 
        point = list(
          events = list(
            click = "#! function() {
                  Shiny.onInputChange('click', {
                    capital: this.capital,
                    country: this.country
                  })
                } !#"))
      )
    )
    a$addParams(dom = "chart")
    return(a)
  })
})