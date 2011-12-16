#!/usr/bin/env python

import re
import string

s = 'MAZ002>004-008>010-013-015-NHZ011-211240-'
state = 'MA'

prefix = state + 'Z'
bad0 = '[^%s]' % state[0]
bad1 = '[^%s]' % state[1]
bad = '((%s.)|(.%s))Z\d\d\d.*$' % (bad0, bad1)

zpat = '(\d\d\d)'
rpat = '(\d\d\d)>(\d\d\d)'

s = re.sub(bad, '', s)

d = {}
l = re.findall(zpat, s)
for x in l:
    d[prefix+x] = 1

l = re.findall(rpat, s)
for start, end in l:
    start = string.atoi(start)
    end = string.atoi(end)
    for x in xrange(start, end+1):
        d['%s%03d' % (prefix, x)] = 1

t=d.keys()
t.sort()
print t

