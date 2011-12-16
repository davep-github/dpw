#!/usr/bin/env python

import os, sys, math

def eval_file(f):
    while 1:
        l = f.readline()
        if not l:
            break
        n = eval(l)
        print n
    
if len(sys.argv) > 1:
    for fname in sys.argv[1:]:
        f = open(fname)
        eval_file(f)
else:
    eval_file(sys.stdin)
