#!/usr/bin/env python

import os, sys, string, getopt

verbose = 0

display_tree = 0
print_cmds = 1
do_cmds = 1
    
class pkg_node_list:
    def __init__(self, pkg_path):
        self.pkg_path = pkg_path
        self.nodes = {}

    def add_node(self, node):
        basename = os.path.basename(node.pathname)
        if verbose:
            print >>sys.stderr, 'basename>%s<' % basename
        self.nodes[basename] = node
        
    def gather_dir(self, arg, dirname, names):
        if verbose:
            print >>sys.stderr, 'gather_dir(%s, %s)' % (arg, dirname)
        node = pkg_node(dirname)
        self.add_node(node)

    def build_list(self):
        os.path.walk(self.pkg_path, self.gather_dir, None)

    def get(self, name, deflt=None):
        return self.nodes.get(name, deflt)

class pkg_node:
    def __init__(self, pathname):
        self.pathname = pathname
        self.read_required_by()
        self.deleted = 0

    def read_required_by(self):
        self.required_by = []
        try:
            f = open(os.path.join(self.pathname, '+REQUIRED_BY'))
        except IOError:
            return

        while 1:
            l = f.readline()
            if not l:
                break
            self.required_by.append(string.strip(l))
        f.close()

    def del_pkg(self, indent=''):
        if display_tree:
            print >>sys.stderr, \
                  '%sdel_pkg>%s<' % (indent, os.path.basename(self.pathname)),
            
        if self.deleted:
            if display_tree:
                print >>sys.stderr, '********* ALREADY DELETED.'
            return
        
        sys.stderr.write('\n')
        
        for req in self.required_by:
            # print >>sys.stderr, '%sreq by>%s<' % (indent, req)
            t = indent
            if t:
                t = t[0:-3] + '|  '
            nn = node_list.get(req)
            if nn:
                nn.del_pkg(t + '`--')
            else:
                print >>sys.stderr, '***node for req>%s< is None***' % req

        del_cmd = 'pkg_delete %s' % self.pathname
        if display_tree:
            print >>sys.stderr, '%s%s' % (indent, del_cmd)
        if print_cmds:
            print del_cmd

        if do_cmds:
            status = os.system(del_cmd)
            ##
            # print 'would: status = sys.system(%s)' % del_cmd
            # status = None
            ##
            if status:
                print >>sys.stderr, "%s failed. exiting." % del_cmd
                sys.exit(2)
        
        self.deleted = 1

options, args = getopt.getopt(sys.argv[1:], 'tvnV:q')
if ('-t', '') in options:
    display_tree = 1
    do_cmds = 0
    
if ('-n', '') in options:
    do_cmds = 0
    print_cmds = 1
    
if ('-v', '') in options:
    print_cmds = 1

if ('-q', '') in options:
    print_cmds = 0

for o, v in options:
    # print 'o>%s<, v>%s<' % (o, v)
    if o == '-V':
        verbose = eval(v)
	break;

node_list = pkg_node_list('/var/db/pkg')
node_list.build_list()

for arg in args:
    if arg[-1] == '/':                  # often added by bash completion
        arg = arg[0:-1]
    # use basename if there is one
    a2 = os.path.basename(arg)
    if a2:
        arg = a2
    node = node_list.get(arg)
    if node:
        node.del_pkg()
    else:
        print 'canna find node for %s' % arg
