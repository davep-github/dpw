#!/bin/bash
# $Id: build-patches.sh,v 1.3 2002/11/27 08:30:10 davep Exp $
# build-patches.sh [dest]
# 
# Walk down dir tree from .
#  find all files *.ORIG
#  Create patch named =.patch, in $dest/=.ORIG's dirname/=.patch
#  
#set -x

def_tdir=$HOME/patches/$(basename $PWD)
tdir=${1:-$def_tdir}
mkdir -p $tdir

for f in `find . -name '*.ORIG' `
do
  new_file=$(echo $f | sed 's,\.ORIG,,')
  # trim the leading .
  # if the find changes, then this must change, too.
  f2=$(echo $f | cut -c2-)
  dir=$(dirname $f)
  diff_file=$(echo $f2 | sed 's,\.ORIG,.diff,')
  #echo "diff_file1>$diff_file<"
  diff_file=$(namify-path -d- $diff_file)
  echo "diff_file>$diff_file<"
  diff -u $f $new_file >| $tdir/$diff_file
done
