# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


inv_table = function(input, output, session){
    inv_table_maker = reactive({ 
        x = d$tickets[,.(ticket_id, ticket_notes, ticket_timestamp, ticket_organization, ticket_category)]
        # search
        if(input$INV_organization != '- all organizations -'){
            setkey(x, ticket_organization)
            x = x[ticket_organization == input$INV_organization]
        }
        if(input$INV_ticket_category != '- all categories -'){
            setkey(x, ticket_category)
            x = x[ticket_category == input$INV_ticket_category]
        }
        #if(nrow(x) > 0){
        #x = make_table(x$ticket_id, 'Ticket', '# of observables')
        x = x[grep(pattern = input$INV_regex, x$ticket_notes),]
        #}
        x$ticket_notes = NULL
        setkey(x, ticket_timestamp)
        
        #if a user clicks a row, update the text box in ticket_details with the ticket_id
        s = input$INV_table_rows_selected
        if(length(s)){
          #log user selections to the console
          #cat('\n\nSelected row index:', s)
          #cat('\nSelected id:', x[s, ]$ticket_id)          
          updateTextInput(session, 'INV_ticket_select', value = x[s, ]$ticket_id)
        }
        
        setnames(x, c("Ticket ID","Time reported", "Organization", "Category")) 
        return(x)
    })
    
    DT::renderDataTable(
        inv_table_maker(),
        selection = list(mode='single'),
        options = list(
                lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
                pageLength = 10, 
                searching = FALSE,
                autoWidth = TRUE #
        ),
        rownames = FALSE,
        server = TRUE
    )
}
output$INV_table = inv_table(input, output, session)
