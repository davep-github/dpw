#!/bin/sh
echo xdm.sh started $(date) >> /tmp/xdm.sh.log
cd /tmp
#ktrace /usr/X11R6/bin/xdm
/usr/X11R6/bin/xdm -debug 4 >> /tmp/xdm.sh.log 2>&1
