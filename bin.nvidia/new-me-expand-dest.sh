#!/bin/sh

if (($# > 1))
then
    extra="--sb $2"
else
    extra=''
fi
~/lib/pylib/sandbox_relativity.py --expand-dest="$1" --abbrev-suffix="__ME_src" $extra
