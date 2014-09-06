#!/bin/bash
#set -x

: ${max_loops:=20000}
: ${recal_threshold:=2}          # seconds
: ${zzz:=10}
: ${time_server:=bitsy.mit.edu}
: ${max_cals:=100}

loops_till_recal=0
total_recal_loops=0
loop_num=0
num_recals=0

# We run until max_loops goes by without a recalibration being needed.
while [ $((loop_num++)) -lt "$max_loops" ]
do
  line=$(ntpdate -q $time_server | egrep '[0-9]+ offset')
  set -- $line
  #  1   2        3               4      5    6      7         8      9       10  11
  # 24 Nov 21:22:04 ntpdate[13753]: adjust time server 18.72.0.3 offset 0.425744 sec
  shift
  offset=$9
  f1=$(echo $offset | sed 's/\([0-9][0-9]*\.[0-9][0-9]\).*/\1/')
  : $((++loops_till_recal))
  if [ $(echo "sqrt($offset ^ 2) > $recal_threshold" | bc) = 1 ]
  then
    echo ""
    ntpdate $time_server
    adjtimexconfig
    echo "loops till recal needed: $loops_till_recal"
    : $((total_recal_loops += loops_till_recal))
    : $((++num_recals))
    echo "avg loops/recal: $((total_recal_loops/num_recals))"
    cat /etc/conf.d/adjtimex | tee /tmp/calibrate-sys-clock.log
    loops_till_recal=0
    loop_num=0
  fi
  echo -n "$f1;"
  sleep $zzz
done
echo ""
echo "DONE"
