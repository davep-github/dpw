#!/usr/bin/env python

import os, sys, re, string

def tr(ifile, ofile):
    while 1:
        l = ifile.readline()
        if not l:
            break
        if l[-1] == '\n':
            l = l[:-1]
        ofile.write(l + '\r\n')

args = sys.argv[1:]


tr(sys.stdin, sys.stdout)

sys.exit(0)


