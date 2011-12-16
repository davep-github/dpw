#!/usr/bin/env python

import os, string, sys, getopt

outbuf = ''
outlist = []
pad_val = chr(0xff)
pad_len = 1<<20

options, args = getopt.getopt(sys.argv[1:], 'p:l:')
for opt, val in options:
	#print "opt", opt, "val", val
	if opt == '-p':
	    pad_val = chr(eval(val))
        if opt == '-l':
            pad_len = eval(val)


for file in args:
    f = open(file)
    outlist.append(f.read())
    f.close

outbuf = string.join(outlist, '')
tlen = len(outbuf)

if tlen < pad_len:
    len_to_pad = pad_len - tlen
    pad_buf = pad_val * len_to_pad
    outbuf = outbuf + pad_buf

sys.stdout.write(outbuf)



    
