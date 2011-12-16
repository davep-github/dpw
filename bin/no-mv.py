#!/usr/bin/env python

import os, sys, string, filecmp
import dp_io

opath = os.path

#!/bin/sh

args="$@"
: ${yn:='n'}

def gather_dir_names(args):
    file_dict = {}
    for d in args:
        dir_names[opath.dirname(a)] = opath.basename(a)
    return file_dict

def del_em(file_dict, dest_dir):
    for d, files in file_dict.keys():
        if os.isdir(d):
            glob = '*'
            dp_io.printf("arg %s is a dir, glob(%s)? ", d, glob)
            a = sys.stdin.readline()
            if a == "\n":
                a =  glob
            files = os.listdir(glob)
        for f in files:
            # if dest_file exists and is the same, del in src.:
            dest_file = os.join(d, f)
            num = 0
            while os.exists(dest_file):
                if filecmp.cmp(f, dest_file):
                    os.unlink(f)
                dp_io.printf("dest_file(%s) exists copying with modified name\n",
                             dest_file)
                name, ext = opath.splitext(dest_file)
                dest_file = name + "-" + str(num) + ext
                num += 1
            print "os.rename(%s, %s)" % (f, dest_dir)
        remains = os.listdir(d)
        if remains:
            ans = "n"
            dp_io.printf("files remain in src dir(%s); Remove them(y/N)? ", d)
            ans = sys.std
            
            
            
            
            
        

    
doomed_dir=$(dirname $1)
     
#set -x
echo "yes $yn | mv -i $@"
yes $yn | mv -i "$@"

doomed=("$@")                   # args
# Rm final directory arg.
doomed1=${doomed[*]:0:$((${#doomed[*]}-1))} # args[:-1]
doomed_files="${doomed1[@]}"    # Make regular string.
# See which files remain.
doomed_files="$(ls -C $doomed_files 2>/dev/null)"
echo "Remains:"
echo "doomed_files>$doomed_files<"
if [ -n "$doomed_files" ]
then
    echo -n 'Remove remaining files[Y/n]? '
    read ans
    [ -z "$ans" ] && ans=y
    [[ "$ans" != [yY] ]] && exit 2
    rm -f $doomed_files
    doomed_files=
fi
## ?? Auto rmdir if no (more) doomed_files?
echo -n 'Remove dir[Y/n]? '
read ans
[ -z "$ans" ] && ans=y
[[ "$ans" != [yY] ]] && exit 2
rmdir $doomed_dir 

