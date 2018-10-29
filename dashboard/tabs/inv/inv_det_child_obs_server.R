# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


inv_child_table = function(input, output, session){
    inv_child_maker = reactive({
        ticket_select = input$INV_ticket_select #ticket_select = 'INC000000299454'
        x = d$observables[ticket_id == ticket_select, .(observable_value, observable_type)]
        setnames(x, c('Observable', 'Type'))
        return(x)
    })
    
    DT::renderDataTable(
        inv_child_maker(),
        options = list(
                lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
                pageLength = 10, 
                searching = FALSE,
                autoWidth = TRUE #
        ),
        rownames= FALSE
    )
}
output$INV_child_table = inv_child_table(input, output, session)