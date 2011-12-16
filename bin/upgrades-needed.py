#!/usr/bin/env python

import sys, os, string, re
import dp_utils
import build_upgrade_script

"""Ask portupgrade for a list of what is out of date.
Create an easily editable script of update commands.
This can then be edited and run to upgrade the system"""

find_upgrades_needed_cmd='sudo portupgrade -Oran'

parse_marker = re.compile('--->  Reporting the results')
scanning = 1

no_sort = 0

# interesting lines look like this(+ --> upgrade is needed)
#	- archivers/freeze (freeze-2.5_1)
#	+ security/racoon (racoon-20011215a)
#
#upgrade_pattern = re.compile('^\s*\+.*?([^/]+)\s+')
upgrade_pattern = re.compile('^\s*\+.*?\(([^)]+)\)')

if len(sys.argv) > 1:
    f = open(sys.argv[1])
elif not sys.stdin.isatty():
    f = sys.stdin
else:
    f = os.popen(find_upgrades_needed_cmd, 'r')

ports = []
portupgrade = None
while 2:
    tline = f.readline()
    if not tline:
        break
    tline = tline[:-1]
    #print 'tline>%s<, scanning: %d' % (tline, scanning)
    if scanning:
        if parse_marker.search(tline):
            scanning = 0
    else:
        m = upgrade_pattern.search(tline)
        if m:
            p = m.group(1)
            if re.search('^portupgrade', p):
                portupgrade = p
            else:
                ports.append(m.group(1))
            #print 'port>%s<' % m.group(1)

if not no_sort:
    ports.sort()

if portupgrade:
    ports.insert(-1, portupgrade)

#print 'ports>%s<' % ports
build_upgrade_script.build_script_from_list(ports)

#print 'done.'


