# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


## Configure:
bin.bounds = c(1, 2, 3, 4, 15, 50)

cmv_aggregate_barplot = function(input){
    plot_maker = reactive({
        x = d$observables
        x$target = x[, input$CMV_ticket_or_obs, with = FALSE]
        x = x[,.(target, ticket_organization, observable_type)]
        if(input$CMV_organization != '- all organizations -'){
            setkey(x, ticket_organization)
            x = x[ticket_organization == input$CMV_organization]
        }
        if(input$CMV_obs_type != '- all types -'){
            x = x[observable_type == input$CMV_obs_type]
        }
        out = rsrc::binned_frequency_table(x$target, bin.bounds)
        if(input$CMV_include_bin1 == 'yes'){
            out = out[out$label!= 1,]
        }
        
        if(input$CMV_ticket_or_obs == 'ticket_id'){
            main_lab = paste0('Tickets: Frequency distribution of the number ',
                                'of observables that get mentioned in each ticket')
            x_lab = "Number of observables mentioned in a ticket"
            y_lab = "Number of tickets"
        }else{
            main_lab = paste0('Observables: Frequency distribution of the number ',
                                'of tickets containing each observable')
            x_lab = "Number of tickets that mention an observable"
            y_lab = "Number of observables"
        }
        
        outplot = barplot(out$count, names.arg = out$label, cex.lab = 1.5,
                          xlab = x_lab, ylab = y_lab, main = main_lab, 
                          cex.axis = 1.5, cex.names = 1.5)
        return(outplot)
    })
    renderPlot(plot_maker())
}
output$CMV_aggregate_barplot = cmv_aggregate_barplot(input)
