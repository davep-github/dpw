#!/usr/bin/env python

import os, sys, string, re

for p in sys.argv[1:]:
    ds = string.split(p, '/')
    p2 = ''
    print 'ds[0]>%s<' % ds[0]
    if ds[0] == '':
        ds[0] = '/'
    for d in ds:
        p2 = os.path.join(p2, d)
        p2 = os.path.normpath(p2)
        #print 'ps>%s<' % p2
        os.system('ls -ld ' + p2)
                 
