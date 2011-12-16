#!/usr/bin/env python

import sys, os, getopt

options, args = getopt.getopt(sys.argv[1:], 'p')
for (o, v) in options:
    if o == '-p':
        print os.getcwd()

for arg in args:
    try:
        link_val = os.readlink(arg)
        print "%s -> %s" % (arg, link_val)
    except OSError:
        pass
    
sys.exit(0);

