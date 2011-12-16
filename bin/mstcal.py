#!/usr/bin/env python
#
# $Id: mstcal.py,v 1.2 2002/03/03 08:30:05 davep Exp $
#
import sys
import os
import urllib
import htmllib
import formatter
import StringIO
import time
import string
import re

"""
Get an mst schedule from the sci-fi website and convert it to
a format usable by pcal.
usage: mstcal.py [mon [year]]
"""

now = time.localtime(time.time())
argc = len(sys.argv)
if argc > 1:
    mon = eval(sys.argv[1])
else:    
    mon = now[1]
if argc > 2:
    year = eval(sys.argv[2])
else:    
    year = now[0]

# old url
#url="http://www.scifi.com/bin/schedulebot.cgi?wd=w&s=MST3000&ds=1&db=US%%3AEastern&mon=%s.%d&t=off&x=128&y=31" % (mon, year%100)

# current url
url='http://www.scifi.com/schedulebot/index.php3?program=MYSTERY+SCIENCE+THEATER+3000&x=94&y=44'


#print 'url:', url

#sys.exit(0)

try:
    u = urllib.urlopen(url)
    s = u.read()

    sf = StringIO.StringIO()
    a = formatter.AbstractFormatter (formatter.DumbWriter(sf))
    p = htmllib.HTMLParser (a)
    p.feed(s)
    sf.seek(0)

    text = sf.readlines()

    for l in text:
        print '>%s<' % l,

    sys.exit(22)
    
    if len(text) == 0:
        raise 'IOError', 'no data'

    #print 'text:', string.join(text, "")

    day_re = re.compile('^(Sat|Sun)')
    split_re = re.compile('^([^,]+),\s+(\S+)\s+(\d+)\s+(.*)$')

    for l in text:
        #print 'l:', l
        # next if !/^(Sat|Sun),/;
        if not day_re.search(l):
            continue
        m = split_re.search(l)
        (dayname, mon, day, rest) = m.group(1, 2, 3, 4)
        rest = re.sub('#', '\\#', rest)
        rest = re.sub('\s+', ' ', rest)
        m = re.match('(...)', mon)
        mon = m.group(1)

        print mon, day, rest
except Exception, e:
    print >> sys.stdout, 'Failed: %s' % e
    sys.exit(1)

sys.exit(0)
    
