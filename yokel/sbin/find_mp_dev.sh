#!/bin/sh
#set -x

VERBOSE=:
[ x"$1" = "x-v" ] && {
    VERBOSE=echo
    shift
}

find_mp_dev ()
{
    mp=$1
    # find the dev associated w/the device
    #/dev/da0c		/jaz		ufs	rw,noauto	0	0
    script='{if ($2 == "'$mp'") print $1;}'
    #echo $script
    x=`awk "$script" /etc/fstab | head -1`
    echo $x
}

for fs in $*
do
    $VERBOSE -n "$fs: "
    x=`find_mp_dev $fs`
    $VERBOSE -n "mounts on "
    echo $x
done
