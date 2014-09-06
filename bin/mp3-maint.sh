#!/bin/bash
set -x

music_dir='/media/music'
start_file="/usr/tmp/mp3-maint-start-file.$$"
maint_file="$music_dir/last_maint_file"

touch $start_file

if [ -f $maint_file ]
then
    newer="-newer $maint_file"
else
    newer=''
fi

eko find . -name '*.[Mm][Pp]3' $newer -print
find $music_dir -name '*.[Mm][Pp]3' $newer -print \
    | sort | uniq | mp3butler -fncI | sh

touch -r $start_file $maint_file

rm -f $start_file

build-album-playlists.py

exit 0

