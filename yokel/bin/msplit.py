#!/usr/bin/env python

import os, sys, string, stat

if len(sys.argv) != 3:
    print >>sys.stderr, "Wrong number of args, need: file obase"
    sys.exit(2)
    
file = sys.argv[1]
obase = sys.argv[2]
# XXX fix this vvvvvvvvvvvvv
tmp_file = '/tmp/msplit.tmp'

resid = os.stat(file)[stat.ST_SIZE]
f = open(file)
chunk_size = 1024*1024 * 10

iter = 0
while resid:
    if resid < chunk_size:
        num = resid
    else:
        num = chunk_size

    d = f.read(num)
    ofile = obase % iter
    of = open(tmp_file, 'w')
    of.write(d)
    of.close()
    cmd = 'mcopy %s %s ' % (tmp_file, ofile)
    print cmd
    os.system(cmd)

    iter += 1
    resid -= num

f.close()
