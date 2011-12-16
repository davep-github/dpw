#!/bin/sh

while read l
do
    case "$l" in
	*upgraded,\ *newly\ installed,\ *to\ remove\ and\ *\ not\ upgraded.)
    s=`echo "$l" | sed -n 's!\([0-9][0-9]*\) upgraded, \([0-9][0-9]*\) newly installed, \([0-9][0-9]*\) to remove and \([0-9][0-9]*\) not upgraded.!\1 \2 \3!p'`
	    echo ">>>>>>>$s<<<<<<<<<<"
	    echo "FOUND IT!" ;;	
	*) echo "]$l[";;
    esac
done
