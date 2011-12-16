#!/bin/sh
#set -x

ops=$*

dirpat="*/CVS .[a-zA-Z]*/CVS"
dirs=`echo $dirpat`
[ "$dirs" = "$dirpat" ] && {
    if [ -d CVS ]
    then
	dirs="."
    else
	echo 1>&2 "No CVS subdirs."
	exit 1
    fi
}

ROOT=`pwd`

for dir in $dirs
do
    d=`dirname $dir`
    echo "checking $d"
    cd $ROOT
    cd $d
    cvs $ops
done

exit 0

