# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


output$INV_notes = renderUI({
    note = subset(d$tickets, ticket_id == input$INV_ticket_select, select=c('ticket_notes'))
    ret = paste("<h3>Notes:</h3>", note)
    HTML(ret)
})

# output$INV_worklogs = renderUI({
#     wklog_title = paste("<h3>Worklog</h3>")
#     # collect all worklog entries & fields for the ticket id
#     wklog_entries = subset(d$worklogs, ticket_id == input$INV_ticket_select, select=c('worklog_long_description')) 
#     # count the number of entries and format for display
#     wklog_count = paste("<b>Total Worklog Entries:", nrow(wklog_entries), "</b><br/>")
#     # pretty numbering and formating of each worklog entry.
#     temp = " "
#     if(!is.null(wklog_count)){        
#         for(index in 1:nrow(wklog_entries)){
#             row = wklog_entries[index, ]            
#             row = gsub("\n", "<br/>", row)
#             row = gsub("\\n", "<br/>", row)
#             temp <- paste(temp, "<br/><b>Worklog Entry", index, ":</b><br/>", row, "<hr>")
#         }
#     }        
#     # display worklog information
#     HTML(wklog_title, wklog_count, temp)
# })  

