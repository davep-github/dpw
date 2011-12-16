#!/usr/bin/env python

import os, sys, getopt, string, re, dp_io, types



field_nums = []
for fld in sys.argv[1:]:
    if fld.isdigit():
        field_nums.append(eval(fld))
    else:
        field_nums.append(fld)

infile = sys.stdin
ofiles = (sys.stdout,)
while 1:
    line = infile.readline()
    if not line:
        break

    if re.search('^\s*#', line):
        continue

    fields = string.split(line)
    f = fields                          # for use in user expressions
    e = []
    for fld in fields:
        if fld[0].isdigit():
            e.append(eval(fld))
        else:
            e.append(fld)
            
    sep = ''
    for fld in field_nums:
        dp_io.fprintf(ofiles, sep)
        try:
            if type(fld) == types.IntType:
                dp_io.fprintf(ofiles, fields[fld])
            else:
                #dp_io.printf('fld>%s< ', fld)
                dp_io.fprintf(ofiles, '%s', eval(fld))
        except IndexError:
            dp_io.fprintf(ofiles, '<<<no-fld>>>')
        sep = ' '
    dp_io.fprintf(ofiles, '\n')
    
