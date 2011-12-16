#!/usr/bin/env bash
#
# $Id: isp-pings,v 1.8 2004/10/06 08:20:03 davep Exp $
# 
# isp-pings: ping a list of sites to see where things are hosed.
#set -x

. ping-lib.sh

: ${sleep_time:= 15}
: ${num_errors:= 0}             # allows us to continue after stopping
[ -z "$ISP" ] && ISP=$($HOST_INFO -n speakeasy.net ISP)

# respond better to ^C (SIGINT)
for sig in 2 3 4 5 6 7 8 15
do
  trap "echo ; echo $0: Got sig $sig, exiting.; exit $sig" $sig
done

while :
do
  if pingit 66.92.73.1 '(GW) '
  then
    stat='OK  '
  else
    stat='FAIL'
    num_errors=$(( $num_errors + 1 ))
    last_fail_time="last failure: $(date)"
  fi
  
  echo "num_errors: " $num_errors "; stat: $stat $last_fail_time"
  date
  echo ''
  sleep $sleep_time
done
