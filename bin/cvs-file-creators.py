#!/usr/bin/env python
import sys, os, re, string

# pipe cvs log into this
# example usage:
# cvs log 2>/dev/null | cvs-file-creators.py | fgrep davep | wc -l
# this works, too:
# cvs log -r1.1 -wdavep|grep '^revision 1.1'|wc -l

WAITING = 'waiting for 1.1'
GOT = 'got 1.1'
state = WAITING
while 1:
    line = sys.stdin.readline()
    if not line:
        break

    if state == WAITING:
        if re.search('^revision 1\.1$', line):
            state = GOT
    elif state == GOT:
        #print line
        m = re.search('author: (\w+)', line)
        print m.group(1)
        state = WAITING
    else:
        print 'illegal state: %s' % state
        state = WAITING
        
        
    
