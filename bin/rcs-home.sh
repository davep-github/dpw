#!/bin/sh
# $Id$
#set -x

: ${vfile:=/dev/null}
: ${home:=$HOME}

dash_n=
dash_v=


for i in $*
do
    case $1 in
	-v) vfile=/dev/tty; dash_v='-v';; # verbose
        -L) LOG_FILE=/dev/null;;
	-n) dash_n='-n';;
	--) shift ; break ;;
	*) 
	    echo 1>&2 "Unsupported option>$1<";
	    exit 1 ;;
    esac
    shift
done

RCS_DIR="/sundry/davep/RCS/RCS.${HOSTNAME}/home.davep/"
#echo "RCS_DIR>$RCS_DIR<"
#echo "$RCS_DIR"
#exit 99
: ${LOG_FILE:="$LOG/rcs-home.log"}

echo '=============================' >> "$LOG_FILE"
date >> "$LOG_FILE"

cd $home

ftreewalk.py . | while read x 
do    
    echo "$x" | rcstreefile-dev "$dash_n" "$dash_v" -r "$RCS_DIR" 
done 2>&1 | tee "$vfile" >> "$LOG_FILE"

date >> "$LOG_FILE"
echo '=============================' >> "$LOG_FILE"

