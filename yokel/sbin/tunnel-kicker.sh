#!/bin/sh

zzz()
{
    echo 'zzz...'
}

if test -t 1
then
    ZZZ=zzz
else
    ZZZ=:
fi

pid_file="$1"
if [ -n "$pid_file" ]
then
    echo "$$" > $pid_file
fi

while :
do    
    crl-on
    eval $ZZZ
    sleep $((60 * 10))
done
