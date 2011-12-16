#!/usr/bin/env python

import os, sys, string, nntplib, getopt

server = 'news.ne.mediaone.net'

group = sys.argv[1]
last_date = '010101'
last_time = '010101'

server = nntplib.NNTP(server)

def dump_subjects(server, first, last):
    resp, subjects = server.xhdr('subject', first + '-' + last)
    for x in subjects:
        print x[1]

def dump_headers(server, first, last):
    for x in xrange(int(first), int(last)+1):
        try:
            resp, num, id, headers = server.head(`x`)
        except nntplib.NNTPTemporaryError:
            print `x`, ' has expired'
        print string.join(headers, '\n  ')
        print '--'

#resp, arts = server.newnews(group, last_date, last_time)
resp, count, first, last, name = server.group(group)
print 'count:', count, 'first:', first, 'last:', last, 'group:', group

dump_subjects(server, first, last)

server.quit()

