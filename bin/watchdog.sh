#!/bin/sh
#set -x

timeout=${1:-300}
command=${2:-"exit 0"}

while :
do
    trap "echo trap" 2 3 4 5 6 7 8 9 15 30
    sleep $timeout
    rc=$?
    echo $rc
    if [ "$rc" = "130" ]
    then
	echo 'sleep interrupted, continuing'
	continue
    fi
    if [ "$rc" != "0" ]
    then
	echo 2>&1 "sleep failed, rc: $rc, exiting"
	exit 1
    fi
    
    echo "timer expired..."
    echo $command
    eval $command
    exit 99
done