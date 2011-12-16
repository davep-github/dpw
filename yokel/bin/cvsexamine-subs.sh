#!/bin/sh
#set -x

prog=`basename $0`

set -- ` getopt qva $* `
[ $? != 0 ] && Usage

Usage()
{
    echo 1>&2 "$prog: usage: [-avq]"
    echo 1>&2 "Examine all CVS maintained subdirs for pending actions."
    echo 1>&2 "  -a|-v   Display all results"
    echo 1>&2 "  -q      Display interesting results"

    exit 1
}

for i in $*
do
    case $1 in
	-q) quiet=y;;
	-a|-v) all=y;;
	--) shift ; break ;;
	*) Usage;;
    esac
done

[ -t 1 ] && . setemph -t

cvs-op-on-subs.sh -n update 2>&1 | while read line
do
    # echo "orig_line>$line<"
    case "$line" in
	cvs" "*": "*) [ "$quiet" = "y" ] && continue;;
	checking*) ;;
	\?*) [ -z "$all" ] && continue;;
	*) line="${emph}${line}${norm}";;
    esac
    # echo "new_line>$line<"
    echo "$line"
done

