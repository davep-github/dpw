#!/usr/bin/env python

import os, sys, getopt, re, string, dp_io, ID3

#dp_io.debug_on()
dp_io.debug_off()

rnode = None

class root_node:
    def __init__(self, rname, name=None):
        self.rname = rname
        self.name = name
        self.dir_nodes = {}


    def get_name(self):
        return self.name or self.rname


    def get_dir_node(self, name):
        return self.dir_nodes[name]

    
    def add_dir(self, dir, name=None):
        dnode = dir_node(dir, name)
        self.dir_nodes[dnode.get_name()] = dnode
        return dnode


    def visit_0(self, name):
        dp_io.debug('root, visit>%s<\n', name)
        dnode = self.get_dir_node(name)
        dnode.visit()
        
    def visit(self):
        dp_io.printf("root: %s\n", self.get_name())
        snames = self.dir_nodes.keys()
        snames.sort()
        for name in snames:
            visit_0(name)


    def descend(self, name, components=None):
        if components == None:
            components = []
        components.append(name)
        dnode = self.get_dir_node(name)
        dnode.descend_all(components)
        
        
    def descend_all(self):
        snames = self.dir_nodes.keys()
        snames.sort()
        component_list = []
        components = []
        for name in snames:
            self.descend(name, components)
            self.component_list.append(components)
        
            

class dir_node:
    def __init__(self, dname, name):
        self.dname = dname
        self.name = name
        self.file_nodes = {}


    def get_name(self):
        return self.name or self.dname


    def get_file_name(self):
        return self.name or self.dname

    def get_file_node(self):
        return self.file_nodes[self.get_file_name()]
    
    def add_file(self, fname, name=None):
        fnode = file_node(fname, name)
        self.file_nodes[fnode.get_name()] = fnode
        return fnode


    def visit(self):
        dp_io.printf("  dname: %s\n", self.get_name())
        snames = self.file_nodes.keys()
        snames.sort()
        for name in snames:
            dp_io.debug('  dir, visit>%s<\n', name)
            if os.path.isdir(name):
                dnode = rnode.add_dir(name)
                dnode.visit()
                continue
            fnode = self.file_nodes[name]
            fnode.visit()

    def descend(self, components=None):
        if components == None:
            components = []
        components.append(name)
        fnode = self.get_file_node(name)
        dnode.descend_all(components)
        
        
    def descend_all(self, components=None):
        if components == None:
            components = []
        name = self.get_name()
        components.append(name)
        fnode = self.get_file_node()
        dnode.descend(components)


class file_node:
    def __init__(self, fname, name):
        self.fname = fname
        self.name = name

    def get_name(self):
        return self.name or self.fname

    def visit(self):
        dp_io.printf("    fname: %s\n", self.get_name())

    def descend(self, components=None):
        components.append(self.name)
        self.process_components(components)

    def process_components(self, components):
        for c in components:
            print '>%s<\n' % c
            

def visit_dir(rnode, dirname, fnames):
    dp_io.printf("%s\n", dirname)
    dnode = rnode.add_dir(dirname)
    for filename in fnames:
        dnode.add_file(filename)
        
        
def tree_walk(root):
    print "vvvvvvvvvvv", arg, "vvvvvvvvvvv"
    global rnode
    rnode = root_node(arg)
    os.path.walk(root, visit_dir, rnode)


if __name__ == "__main__":
    
    for arg in sys.argv[1:]:
        print "===========", arg, "==========="
        tree_walk(arg)
        #rnode.visit()
        rnode.descend_all()
        
