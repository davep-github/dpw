#!/usr/bin/env python

import os, sys, string, nntplib, dp_io

def stringify(t):
    return '%s %s %s %s' % (t[0], t[1], t[2], t[3])

if len(sys.argv) < 2:
    svr = 'netnews.attbi.com'
else:
    svr = sys.argv[1]

svr = nntplib.NNTP(svr);

s = svr.getwelcome()
dp_io.eprintf('Server welcome message:\n%s\n', s)

dp_io.eprintf('getting groups list...\n')
resp, l = svr.list()
dp_io.eprintf('list response >%s<\n', resp)

l2 = map(stringify, l)
l2.sort()
print string.join(l2, '\n')

svr.quit()

sys.exit(0)



    

