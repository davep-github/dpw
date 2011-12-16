#!/usr/bin/env python

"""Purge a pcal appointment file (or any file with lines beginning
with a supported date format) of dates before a given date.  If no
date is specified, then use the current date."""

import os, sys, string, dp_io, time, dp_time, getopt

opts, args = getopt.getopt(sys.argv[1:], 'b:d:')

limit=None
for o, v in opts:
    if o in ('-b', '-d'):
        limit = dp_time.parse_date(v, None, dp_time.GMT)

if limit == None:
    limit = time.time()

dp_io.eprintf('Preserving appts after: %s\n',
              time.strftime('%d-%b-%Y', time.gmtime(limit)))

# print args, len(args)
if len(args) == 0:
    f = sys.stdin
    # print 'using stdin'
else:
    f = open(args[0])
    # print 'using', args[0]

while 1:
    line = f.readline()
    if not line:
        break
    tline = string.strip(line)
    if tline[0] == '#':
        continue

    fields = string.split(tline)
    ltime = dp_time.parse_date(fields[0], None, dp_time.GMT)
    # print 'ltime', ltime, time.ctime(ltime), 'limit', limit, 'ctime:'
    if ltime > limit:
        sys.stdout.write(line)
        
        

