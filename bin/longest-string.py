#!/usr/bin/env python

import sys, os, string, re, getopt

debug = 0

def longest(file):
    max = -1
    while 1:
        l = file.readline()
        if not l:
            break;
        l = string.rstrip(l)
        ll = len(l)
        if ll > max:
            max = ll
            maxl = l

    print max, maxl

options, args = getopt.getopt(sys.argv[1:], 'd:')

#print 'options>%s<' % options
for o, v in options:
    print 'o>%s<, v>%s<' % (o, v)
    if o == '-d':
        debug = debug + 1
	continue

if len(args) == 0:
    longest(sys.stdin)
else:
    for arg in args:
        file = open(arg)
        longest(file)
        file.close()

