#!/bin/sh
#set -x

dirs=`echo */CVS`

for dir in $dirs
do
    d=`dirname $dir`
    echo "checking $d"
    cvsdirty $d
done


