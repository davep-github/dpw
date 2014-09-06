#!/bin/bash
# $Id: ck-gentoo-pkg.sh,v 1.1 2004/09/30 08:20:02 davep Exp $

# e.g.
# obj /usr/bin/python2.3 7f9a8f42a52184a667ea5b8f50c7f6ac 1089256000

con_file=${1:-/var/db/pkg/dev-lang/python-2.3.3-r1/CONTENTS}

cat "$con_file" | while read line
do
  set -- $line
  [ "$1" != "obj" ] && continue
  
  fname="$2"
  hash="$3"
  
  sum=$(md5sum "$fname")
  set -- $sum
  sum="$1"
  
  if [ "$hash" != "$sum" ]
  then
    echo "$fname has bad hash"
    #echo 1>&2 "hash>$hash<, sum>$sum<"
  fi
done

