# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

library("shiny")

shinyUI(pageWithSidebar(    
  headerPanel("Tab Switch Demo"),
  sidebarPanel(
         h4('Switch Tabs Based on Methods'),
             radioButtons(inputId="method", label="Choose a Method",
                          choices = list("method_1",
                                         "method_2")),
         conditionalPanel("input.method== 'method_2' ",                          
                          selectInput("method_2_ID", strong("Choose an ID for method 2"),
                                      choices = list("method_2_1",
                                                     "method_2_2"))
                          )       

    ),
  mainPanel(
          tabsetPanel(id ="methodtabs",
            tabPanel(title = "First Method Plot", value="panel1",
                     plotOutput("method_1_tab1")),
            tabPanel(title = "method_2_output1", value="panel2",
                     tableOutput("m2_output1")),
            tabPanel(title = "method_2_output2", value="panel3",
                     verbatimTextOutput("m2_output2"))
            )
      )  
))