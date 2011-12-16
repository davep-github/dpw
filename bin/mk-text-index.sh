#!/usr/bin/env bash
#
# $Id: mk-text-index.sh,v 1.4 2004/01/28 04:15:22 davep Exp $
#
set -x

prog=`basename $0`
echo $prog: $* 1>&2

ECHO=''
index=''
t_dir=''
t_enabled=''
clean_index='n'
initialize='n'
conf_file_name=''
conf_file=''

Usage()
{
    echo "${prog}: usage: [-$option_str]" 1>&2
    exit 1
}

# init optional vars to defaults here...
ECHO=

# see the man page of getopt for inadequacies.

option_str='ni:d:ecID:C:'
all_options="$option_str$std_options"

# New style getopt... fixes ugly quoting problems.
q=$(getopt -o "$all_options" -- "$@")
[ $? != 0 ] && Usage
eval set -- "$q" 
unset q

for i in "$@"
  do
  case $1 in
      -n) ECHO=eko;;		# show what we would do
      -i) index_name=$2; shift;;
      -d) t_dir=$2; shift;;
      -D) t_index_dir=$2; shift;;
      -e) t_enabled=y;;
      -c) clean_index=y;;
      -I) initialize=y;;
      -C) conf_file=$2; shift;;
      --) shift ; break ;;
      *) 
      echo 1>&2 "Unsupported option>$1<";
      exit 1 ;;
  esac
  shift
done

[ -z "$index_name" ] && Usage

t_args_to_indexer="$@"

. eexec

if [ "$ECHO" = 'eko' ]
    then
    EExecDashN
fi

[[ -z "$conf_file" ]] && {
    conf_file_name="$index_name-index.conf"
    etc_dir=${etc_dir:-"$HOME/etc"}
    conf_file="$etc_dir/$conf_file_name"
}
[ -f "$conf_file" ] && source "$conf_file"

# command line overrides conf file.
[ -n "$t_dir" ] && dir_to_index=$t_dir
[ -z "$dir_to_index" ] && FATAL 1 "I need a dir-to-index"

[ -n "$t_index_dir" ] && index_dir=$t_index_dir
[ -z "$index_dir" ] && FATAL 1 "I need an index-dir."

[ -n "$t_enabled" ] && enabled=$t_enabled
case "$enabled" in
    [yY]|[Yy][Ee][Ss]|1|[tT]);;
    *) FATAL 0 "Indexing for $index_name not enabled";;
esac


EExec cd $dir_to_index

# e.g. allows='pkg-(descr|comment|plist)'
if [ -n "$t_args_to_index" ]
    then
    args_to_indexer=$t_args_to_index
fi

[ -n "$index_dir" ] && [ ! -d "$index_dir" ] && {
    EExec mkdir -p $index_dir
}

echo "index_dir>$index_dir<"

if [ "$initialize" = 'y' ]
    then
    EExec rm -rf $index_dir/*
fi
case "$indexer" in
    [Gg][Ll][Ii][Mm][Pp][Ss][Ee])
    [ -n "$index_dir" ] && index_dir="-H $index_dir"
    $ECHO glimpseindex $args_to_indexer -t $index_dir .
    ;;
    [Nn][Aa][Mm][Aa][Zz][Uu])
    if [ "$clean_index" = 'y' ]
	then
        $ECHO gcnmz $index_dir
    else
        [ -n "$index_dir" ] && index_dir="-O $index_dir"
        $ECHO mknmz $args_to_indexer $index_dir .
    fi
    ;;
esac

exit 0
