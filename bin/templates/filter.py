#!/usr/bin/env python

import sys, os, string, re, getopt

# increase indent w/start, dec w/end

debug = 0

def nest(file):
    while 1:
        l = file.readline()
        if not l:
            break;

options, args = getopt.getopt(sys.argv[1:], 'd:')

#print 'options>%s<' % options
for o, v in options:
    print 'o>%s<, v>%s<' % (o, v)
    if o == '-d':
        debug = debug + 1
	continue

if len(args) == 0:
    nest(sys.stdin)
else:
    for arg in args:
        file = open(arg)
        nest(file)
        file.close()

