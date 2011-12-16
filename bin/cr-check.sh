#!/bin/sh
# $Id$
#set -x

data_file="$1"

: ${data_file:="mfgdata.txt"}

bi_file_line()
{
  bi_file=$(grep -n "$1" "$data_file" | tail -1)
  if [ "$bi_file" = '' ]
  then
    start_line=-1
  else
    oldIFS=$IFS
    IFS=':'
    set -- $bi_file
    IFS=$oldIFS
    start_line=$1
  fi
  
  echo $start_line
}

rc=0
#overall
# e.g.  passed Overall Summary:  passed
overall=$(grep 'Overall Summary:.*pass' $data_file | tail -1)
if [ "$overall" = '' ]
then
  overall='FAIL'              # actually not passed
  rc=1
else
  overall='PASS'
fi

# burnin
bi_start_line=$(bi_file_line 'BURN-IN CR START')
bi_fail_line=$(bi_file_line 'BURN-IN CR FAIL')

if [ "$(( $bi_fail_line > $bi_start_line ))" = '1' ]
then
  bi_stat='FAIL'
  rc=1
else
  bi_stat='PASS'
fi

#wifi
# e.g. "WIFI V1", "FAIL",
# how about frep 'WIFI.*FAIL' so fail anywhere ==> fail
#  since there're a lot of places where "FAIL" occurs.
wifi_stat=$(grep 'WIFI V1.*PASS' $data_file | tail -1)
if [ "$wifi_stat" = '' ]
then
  wifi_stat='FAIL'
  rc=1
else
  wifi_stat='PASS'
fi

echo "overall: $overall"
echo "burnin: $bi_stat"
echo "wifi: $wifi_stat"

exit $rc
