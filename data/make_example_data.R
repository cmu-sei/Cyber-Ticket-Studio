# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345


#
# Generate fake example data.  This is the easiest and fastest way to
# get the app running for a basic demonstration of functionality
#

library(generator)
library(dsim)
library(rsrc)
CONF = rsrc::get_config()

# Vocabularies
vocabs = list()
vocabs$text = dsim::make_vocab(25000)
vocabs$ip = generator::r_ipv4_addresses(5000)
vocabs$email = generator::r_email_addresses(3000)
vocabs$filename = dsim::make_filenames(2000)
vocabs$domain = replicate(2000, dsim::make_domain())

# Documents
n_docs = 5000
docs = replicate(n_docs, dsim::make_document(vocabs))
timestamps = dsim::random_timestamps(n_docs)
organizations = sample(c("Ministry of Love",
                    "Ministry of Peace",
                    "Ministry of Plenty",
                    "Ministry of Truth"), n_docs, replace = TRUE)
categories = sample(c(
    "Phishing",
    "Malware",
    "Test",
    "Lost device",
    "Denial of service"), n_docs, replace = TRUE)

# Save as a csv file
dt = data.frame(
    ticket_id = 1:n_docs,
    ticket_notes = docs,
    ticket_timestamp = timestamps,
    ticket_organization = organizations,
    ticket_category = categories
)
write.csv(dt, file = file.path(CONF$dirs$datdir, "tickets.csv"),
          row.names = FALSE)
