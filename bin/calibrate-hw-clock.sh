#!/bin/sh
set -x

: ${days:=7}                    # Do it for a week.
: ${interval_hrs:=8}
: ${loops:=$[days * (24/interval_hrs)]} # Pure number.
: ${interval:=$[interval_hrs*60*60]} # seconds

adj()
{
    # show current stat
    ntpdate -q bitsy.mit.edu
    date
    hwclock --utc -r
    adjtimex --utc -p

    # adjust it
    ntpdate bitsy.mit.edu
    hwclock --utc --systohc
    adjtimexconfig
}

while [ "$[loops--]" -gt 0 ]
do
    adj
    if [ "$loops" -gt 1 ]
    then
        sleep $interval
    fi
done
