#!/bin/bash
# $Id: search-text-index.sh,v 1.2 2003/12/23 08:30:06 davep Exp $
#set -x

progname=`basename $0`

[ "$#" -lt "1" ] && FATAL 1 "I need an index name."

index_name=$1
shift
conf_file_name="$index_name-index.conf"
etc_dir=${etc_dir:-"$HOME/etc"}
conf_file="$etc_dir/$conf_file_name"


[ -f $conf_file ] && . $conf_file

#
# allow anything to be changed
while [ "$1" = "---E" ]
do
    shift
    eval $1
    shift
done



case "$indexer" in
    [gG][Ll][Ii][Mm][Pp][Ss][Ee])
	# print line numbers so compile-mode in an emacs shell window works.
	glimpse -n -H $index_dir "$@"
	;;
    [Nn][Aa][Mm][Aa][Zz][Uu])
	eko namazu "$@" $index_dir
	namazu "$@" $index_dir
	;;
    ""|[Nn][Oo][Nn][Ee]|[Gg][Rr][Ee][Pp])
	find $dir_to_index -type f -print0 | xargs -0 egrep "$@"
	;;
    *)
	echo 1>&2 "$0: Unsupported indexer($indexer)"
	exit 2
	;;
esac

exit $?

