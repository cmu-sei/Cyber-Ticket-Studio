# Information Discovery
# Copyright 2018 Carnegie Mellon University. All Rights Reserved.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# Released under a BSD-style license, please see license.txt or contact permission@sei.cmu.edu for full terms.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release and unlimited distribution.  Please see Copyright notice for non-US Government use and distribution.
# CERT® is registered in the U.S. Patent and Trademark Office by Carnegie Mellon University.
# DM18-0345

# Classes for loading configuration values from a YAML file
import munch
import os
import pdb
import yaml

# DEFAULTS FOR WORKING WITH OBSERVABLES
class Observables(object):
    minimum_terms_per_doc = 2     # Exclude incidents that contain fewer than this many observables
    # minhash & similarity parameters
    n_hashes = 100
    sim_thresh = 0.00001 #0.5

# DEFAULTS FOR WORKING WITH INCIDENTS
class Tickets(object):
    minimum_terms_per_doc = 2     # Exclude observables that appear in fewer than this many incidents
    # minhash & similarity parameters
    n_hashes = 100
    sim_thresh = 0.00001 #0.5


# Load the user's configuration file
class Config(object):
    def __init__(self):
        cfg_file = os.path.expanduser("~/.cyber_ticket_studio")
        with open(cfg_file, 'r') as f:
            self.cfg = munch.Munch(yaml.load(f))
        self.cfg.repository_pth = os.path.expanduser(self.cfg.repository_pth)
        self.cfg.datdir = os.path.expanduser(self.cfg.datdir)
        self.append_schema()
        self.append_paths()
        self.append_community_detection_settings()

    def repo_home_plus(self, path):
        '''append the repo home path to a sub-path/file'''
        return os.path.join(self.cfg.repository_pth, path)

    def data_home_plus(self, path):
        '''append the repo home path to a sub-path/file'''
        return os.path.join(self.cfg.datdir, path)

    def append_schema(self):
        schema_file = self.repo_home_plus('schema.yml')
        with open(schema_file, 'r') as f:
            schema = munch.Munch(yaml.load(f))
        self.cfg.update({'schema': schema})

    def append_paths(self):
        paths = munch.Munch({
            'db': self.data_home_plus('cyber_ticket_studio.database')
        })
        self.cfg.update({'paths': paths})

    def append_community_detection_settings(self):
        self.cfg.update({'observables': Observables(),
                         'tickets': Tickets()})
