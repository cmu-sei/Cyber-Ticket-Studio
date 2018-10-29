# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


is_valid_repo_directory = function(d){
    files = list.files(d)
    expected_files = c("dashboard", "docs", "README.md", "src")
    failures = setdiff(expected_files, files)
    if(length(failures) > 0){
        print(paste("The directory you specified does not contain ",
                     "these expected items:",
                    paste(failures, collapse = ", ")))
        return(FALSE)
    }
    return(TRUE)
}

is_valid_data_directory = function(d){
    files = list.files(d)
    if(length(files) == 0){
        return(TRUE)
    }else{
        print("That directory is not empty.  Specify an empty directory for the data for this project")
        return(FALSE)
    }
}
request_repo_directory = function(){
    repo_prompt = "Enter the path (without quotes) to your copy of the cyber_ticket_studio repository"
    repo_dir = rsrc::request_directory(repo_prompt)
    while(!is_valid_repo_directory(repo_dir)){
        repo_dir = rsrc::request_directory(repo_prompt)
    }
    return(repo_dir)
}

request_data_directory = function(){
    data_prompt = "Provide the path (without quotes) to an empty directory where this app can place its data"
    data_dir = rsrc::request_directory(data_prompt)
    while(!is_valid_data_directory(data_dir)){
        data_dir = rsrc::request_directory(data_prompt)
    }
    return(data_dir)
}

write_config_file = function(repo_dir, data_dir){
    config_file = "~/.cyber_ticket_studio"
    if(file.exists(config_file)){
        proceed = menu(c("yes", "no"),
                       title=paste0(config_file, " already exists. ",
                                    "Are you sure you want to overwrite this?")
        )
    }else{
        proceed = 1
    }
    if(proceed == 1){
        fileConn = file(config_file)
        writeLines(c(
            paste0("repository_pth: '", repo_dir, "'"),
            paste0("datdir: '", data_dir, "'")
        ), fileConn)
        close(fileConn)
    }
}

#' NOT CURRENTLY WORKING
#' This function prompts the user to provide the info needed for the app
#' to manage relative file paths
initialize_project = function(){
    repo_dir = request_repo_directory()
    data_dir = request_data_directory()
    write_config_file(repo_dir, data_dir)
}
