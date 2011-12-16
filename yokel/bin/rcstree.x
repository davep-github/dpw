#!/bin/sh
#set -x
prog=`basename $0`
echo $prog: $* 1>&2

rcs_suffix=',v'

Usage()
{
   echo "${prog}: usage: $prog -r rcs_root [-t text] [-m msg]" 1>&2
   exit 1
}

# init optional vars to defaults here...
ECHO="echo $prog: "
EKO=':'
text='rcsed_by_rcstree'
msg='rcsed_by_rcstree'
excl_files=''
LINK_FILE="./.rcstree-LINK-list-for-$(basename $PWD)..."

debug=':'			# : -->off, echo -->on

set -- ` getopt t:m:vr:nx: "$@" `

[ $? != 0 ] && Usage

for i in $*
do
    case $1 in
	-t) text=$2; shift; shift;;
	-m) msg=$2; shift; shift;;
	-v) verbose=1; EExecEcho=echo; shift;;
	-r) rcs_root=$2; shift; shift;;
	-n) verbose=1; EExecEcho=echo; EExecShowOnly=y; shift;;
	-x) excl_files="$excl_files $2"; shift; shift;;
	--) shift; break;;
	*) Usage ;;
    esac
done

# only if non optional args required
#[ "$*" = "" ] && Usage

[ -z "$rcs_root" ] && Usage

. /usr/yokel/bin/eexec
EExecContinue=1

PRUNEDIRS="RCS CVS ,RCS-HIDE,"
excludes=
or=
for dir in $PRUNEDIRS
do 
    excludes="$excludes $or -name '$dir' -prune"
    or="-or"
done
[ -n "$excludes" ] && excludes="\\( $excludes \\) -or"

ex_files=
and=
for f in $excl_files
do
    ex_files="$ex_files $and \! -name $f"
    and="-and"
done
[ -n "$ex_files" ] && ex_files="\\( $ex_files \\) -and"

$debug "ex_files>$ex_files<"

#####or=
#####[ -n "$excludes" -a -n "$ex_files" ] && or='-or'

all_excludes="$excludes $ex_files"

$debug "allex>$all_excludes<"

#eko $excludes
#eval eko $excludes
$EKO find . $all_excludes -type f -print
$debug find . $all_excludes -type f -print

# save links into a file.  This will then be rcs'd below
eval find . $all_excludes -type l -ls >| $LINK_FILE

eval find . $all_excludes -type f -print |
while read file
do
    #$debug "file>$file<"
    #continue

    echo "$file" | rcstreefile -r "$rcs_root"
done

