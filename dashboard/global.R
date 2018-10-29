# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

####################################
# Global functions and variables
####################################
rm(list = ls())
#.libPaths(new = "/srv/scratch/ztkurtz/SOFTWARE/R")

# Import R packages
library(DT)
library(rCharts)
library(rsrc)
library(ShinyViews)

###
# User configuration (see `README.md` and `example_config`)
CONF = rsrc::get_config()
# Load data from /data/datafiles/appData/cyber_ticket_studio
d = readRDS(file.path(CONF$dirs$datdir, 'data.RDS'))

# Include clique pair reversals on all similarities to enable related-clique lookups
#   based on only the 'clique1' column
d$ticket_similarities = rsrc::attach_reverse_clique_pairs(d$ticket_similarities)
d$observable_similarities = rsrc::attach_reverse_clique_pairs(d$observable_similarities)

d$metadata = list(
    time_start = as.character(as.Date(min(d$tickets$ticket_timestamp))),
    time_end = as.character(as.Date(max(d$tickets$ticket_timestamp)))
)
