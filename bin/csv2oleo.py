#!/usr/bin/env python

import sys, os, string

#
# example minimal oleo data file:
data='''
C;c1;r1;K123
C;r2;K888.799999999999954
C;r3;K999.899999999999977
C;c2;r1;K456
C;c3;K789
'''

class State:
    def __init__(self):
        self.col_start = 1
        self.row_start = 1
        self.col_prefix = 'c'
        self.col_prefix = 'r'

    def reset(self)
        self.row_num = col_start

args = sys.argv[1:]

def process(infile):
    while 1:
        line = infile.readline()
        if not line:
            break;
        cols = string.split(line, '\s*,\s*')
        for col in cols:
            state.emit(col)
    
for arg in args:
    f = open(arg)
    process(f)
    f.close()

    

