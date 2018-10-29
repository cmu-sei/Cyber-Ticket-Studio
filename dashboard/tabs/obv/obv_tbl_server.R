# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


obv_table = function(input, output, session){
    obv_table_maker = reactive({
        organization = input$OBV_organization
        obs_type = input$OBV_obs_type
        filter_on_organization = (organization != '- all organizations -')
        filter_on_obs_type = (obs_type != '- all types -')
        if( filter_on_organization | filter_on_obs_type ){
            x = d$observables
            setkey(x, ticket_organization)
            if(filter_on_organization) x = x[ticket_organization == organization]
            if(filter_on_obs_type) x = x[observable_type == obs_type]
            if(nrow(x) == 0) return(x)
            x = rsrc::make_table(x$observable_value, 'Observable', '# of tickets')
            x = data.table(x)
            # #######
            # # Append blacklist/campaign information:
            # x = merge(x, d$frequency_tables$blacklists, by = 'Observable', all.x = TRUE)
            # x = merge(x, d$frequency_tables$apt_notes, by = 'Observable', all.x = TRUE)
            # x$blacklist_count[is.na(x$blacklist_count)] = 0
            # x$APT_count[is.na(x$APT_count)] = 0
            # x[,sum:=APT_count + blacklist_count]
            # setorder(x, -sum)
            # x[,sum:=NULL]
        }else{    
            x = d$frequency_tables$obs
        }
        x = x[grep(pattern = input$OBV_regex, x$Observable),]
        #######
        #click a row to update the text box in observable_details with that row's observable 
        if(length(input$OBV_table_rows_selected)){
            updateTextInput(session, 'OBV_obs_select', 
                            value = x[input$OBV_table_rows_selected, ]$Observable)
        }
        return(x)
    })
    DT::renderDataTable(
        obv_table_maker(),
        selection = list(mode='single'),
        options = list(
                lengthMenu = c(1, 2, 3, 5, 7, 10, 15, 25, 40, 60, 100), 
                pageLength = 10, 
                searching = FALSE,
                autoWidth = TRUE,
                columnDefs = list(list(width = '100px', targets = "# of tickets"))
        ),
        rownames= FALSE
    )
}
output$OBV_table = obv_table(input, output, session)
