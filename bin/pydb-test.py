#!/bin/bash

host=${1:-$HOST}

do_it()
{
    echo ">>>""$@"":"
    "$@"
    echo '--'
}

# echo $HOST_INFO -h $host xterm_bg xterm_fg xterm_geometry xterm_bin xterm_font xterm_options

do_it $HOST_INFO -h $host xterm_bg xterm_fg xterm_geometry xterm_bin xterm_font xterm_options family shell

do_it qpydb.py -S -d phonebook -f '.*-home'

# do a search that fails. this will look through every entry and ref
echo 'failing query begin...'
do_it qpydb.py -f '///////extraneous-blahsayety//////'
echo '...failing query end'
