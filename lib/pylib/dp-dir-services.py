#!/usr/bin/env python
# $Id: dp-dir-services.py,v 1.1.1.1 2005/05/05 15:15:57 davep Exp $
# Provide some additional, hopefully useful dir services.
#
import os, sys, getopt, re, string, dp_io, ID3


class hd_hash_node:
    def __init__(self, filename):
        self.filename = filename
        self.containing_dirs = {}


    def add_dir(self, dirname, stat=None):
        self.containing_dirs[dirname] = stat


    def get_size(self, dir=None, full_name=None):
        # check cache and return is non-None
        # else construct file name and ask file system
        try:
            node = hd_hash_nodes[filename]
            size = 
        except KeyError:
            

class hd_hash_node_list():
    def __init__(self):
        hd_nodes = {}


    # size == number --> use size
    # else:
    #   sizef == 'get' (?or non-None?) --> get
    #   sizef == None --> use none.
    def add_node(self, filename, dirname=None, stat=None, statff=None):
        node = get_or_create_hdh_node(filename)
        if not size:
            if sizef:
                if dirname:
                    full_name = os.path.join(dirname, filename)
                    size = os.stat(full_name)
                    
        if dirname:
            node.add_dir(dirname, stat)
        return node


    def get_or_create_hdh_node(self, filename):
        try:
            node = hd_nodes[filename]
        except KeyError:
            node = hd_hash_node(filename)

        return node
        
    

hd_hash_nodes = hd_hash_node_list()

def hd_visit_dir(cache_sizes, dirname, fnames):
    for filename in fnames:
        hd_hash_nodes.add_node(filename, dirname)
    
def hash_dir_tree(root):
    os.path.walk(root, hd_visit_dir, cache_sizes)
    
