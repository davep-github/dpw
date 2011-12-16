#!/usr/bin/env python

import sys, os, string, re

def find_host(addr):
    print '>',
    f = os.popen('host 2>&1 ' + addr)
    s = f.read()
    f.close
    print '<',

    # print 's>%s<' % s
    if s.find('IN-ADDR.ARPA') < 0:
        return None
    else:
        l = string.split(s)
        return l[4]

ip_to_name = {}
ip_count = {}

while 1:
    line = sys.stdin.readline()
    if not line:
        break

    m = re.search("\d+\.\d+\.\d+\.\d+", line)
    if m:
        ip_addr = m.group()
        if ip_to_name.get(ip_addr, '?') == '?':
            # new ip num
            ip_to_name[ip_addr] = find_host(ip_addr)
            ip_count[ip_addr] = 1
        else:
            ip_count[ip_addr] += 1

    else:
        print >>sys.stderr, "badly formatted line>%s<" % line
        
keys = ip_to_name.keys()
keys.sort()
olist = []
for k in keys:
    olist.append('%s : %s [%d]' % (ip_to_name[k], k, ip_count[k]))

olist.sort()

for i in olist:
    print i
    
    
