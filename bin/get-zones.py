#!/usr/bin/env python

import urllib

data = ''
for zn in xrange(1, 64):
    url = 'ftp://weather.noaa.gov/data/forecasts/zone/ma/maz%03d.txt' % zn
    print url
    try:
        u = urllib.urlopen(url)
        print u.read()
    except:
        print 'canna open url'
    print '\n-----------------------\n'
        
