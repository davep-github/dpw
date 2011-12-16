#!/usr/bin/env python

import os, sys, string, re
import dp_io


f = sys.stdin

seen_chars = {}

while 1:
    l = f.readline()
    if not l:
        break
    #dp_io.eprintf("%s", l)
    l = l[0:-1]

    for c in l:
        if c in ':/':
            continue
        seen_chars[c] = c


keys = seen_chars.keys()

dp_io.printf('"')
for k in keys:
    dp_io.printf('%s', k)

dp_io.printf('"\n')

