#!/usr/bin/env python

import os, sys, string

total = 0
for s in sys.argv[1:]:
    s = string.upper(s)
    for c in s:
        if c in ' \t\r\n':
            continue
        #v = ord(c) - ord('a') + 1
        v = ord(c)
        total = total + v
        print 'c:', c, 'v:', v, 'total:', total

sys.exit(0)
