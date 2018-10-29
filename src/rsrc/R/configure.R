# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

#' @description Returns a list of file paths and other project-wide constants.
#' @details The criterion for a configuration value to get specified here
#' (and not just in the script where it's needed) is if the same value
#' will be needed across multiple scripts
#' @param check_dirs If true, check that all defined dirs entries exist on the
#' user's system
#' @param filepath Full path where `example_config` got saved (see CTS `README.md`). The NULL 
#' default is generally sufficient, but you may need to set this separately if you're setting
#' this up in the context of shiny-server.
get_config = function(check_dirs = TRUE, filepath = NULL){
    if(is.null(filepath)) filepath = '~/.cyber_ticket_studio'
    dirs = yaml::yaml.load_file(filepath)
    if(check_dirs) check_directories_exist(dirs)
    return(
        list(
            dirs = dirs
        )
    )
}

check_directories_exist = function(dirs){
    for(D in dirs){
        if(!dir.exists(D)) stop(paste0("directory does not exist: ", D))
    }
}

load_user = function(){
    if(!file.exists('~/.cyber_ticket_studio')){
        stop("You need set up your `~/.cyber_ticket_studio` file -- see `example_config`")
    }
    yaml::read_yaml('~/.cyber_ticket_studio')
}