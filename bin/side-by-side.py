#!/usr/bin/env python

import sys, os, string

width = 80

class eof_obj:
    def readline(*pargs, **kargs):
        return ("*** EOF ***")

def side_by_side(files, width):
    n = len(files)
    pad = " " * width
    sep = " | "
    sep_len = len(sep)
    max_line = (width - (n-1)*sep_len) / n
    lines = [''] * n
    eof_count = 0
    while eof_count < n:
        for i in range(0, n):
            f = files[i]
            line = f.readline()
            if not line:
                f = eof_obj()
                files[i] = f
                line = f.readline()
                eof_count = eof_count + 1
            lines[i] = line
        olines = []
        for line in lines:
            if line[-1] == '\n':
                line = line[:-1]
            line = line + pad
            line = line[:max_line]
            olines.append(line)
        print "%s" % string.join(olines, sep)
            
import getopt
options, args = getopt.getopt(sys.argv[1:], 'w:')
for (o, v) in options:
    if o == '-w':
        width = eval(v)

files = []

for file in args:
    f = open(file, 'r')
    files.append(f)

side_by_side(files, width)
