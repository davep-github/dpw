#!/usr/bin/env python
# $Id: build_upgrade_script.py,v 1.7 2003/11/21 08:30:07 davep Exp $

import string, sys, dp_io

def build_script_from_string(port_list):
    date = dp_io.bq('date')
    #
    # emit a simple shell script
    ports = """#!/bin/sh
# generated: %s
# by: %s
#
log_file=$DP_SUNDRY_LOG/'portupgrade.log'
sudo chmod a+rw $log_file
    
ports='
%s
'

echo "Upgrade started $(date)" >> $log_file

for port in $ports
do
    case "$port" in
    [#\\;]*|//*)
        echo "skipping >$port<"
        continue;;              # skip commented lines
    portupgrade-*)
	sudo pkg_delete /var/db/pkg/ports/$port
	cd /usr/ports/sysutils/portupgrade
	sudo make clean
        sudo make install
	;;
    *)
	echo "upgrading $port..."
	sudo portupgrade "$@" $port || {
	    ret=$?
	    echo 1>&2 "Build of $port failed w/rc $ret"
	    exit $ret
	}
        ;;
    esac
done 2>&1 | tee -a $log_file

""" % (date,
       string.join(sys.argv, " "),
       port_list)

    return ports

def build_script_from_list(port_list):
    print build_script_from_string(string.join(port_list, '\n'))
    
if __name__ == "__main__":
    import sys

    ports = sys.stdin.readlines()
    #print '>%s<' % ports
    print "%s" % build_script_from_string(string.join(ports, ''))
    sys.exit(0)

