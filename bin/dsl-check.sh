#!/bin/bash
# $Id: dsl-check.sh,v 1.2 2004/10/09 08:20:02 davep Exp $

for sig in 2 3 4 5 6 7 8 15
do
  trap "echo ; echo $0: Got sig $sig, exiting.; exit $sig" $sig
done

: ${sleep_time:=$((60*5))}

(
  while :
  do
    date
    isp-pings $1
    sleep $sleep_time
  done
) 2>&1 | tee -a /usr/tmp/dsl-check-log.txt


