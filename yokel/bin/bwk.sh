#!/bin/sh
set -x
date=`dp-std-date`
bw_log_base="bw.out."
bw_log="$bw_log_base$date"

bk_log_base="bk.out."
bk_log="$bk_log_base$date"

bwk_log_base='bwk.out.'
bwk_log="$bwk_log_base$date"

BWF=CFLAGS="-O -pipe -D_OLD_STDIO"
BKF=

ETC_BAK_DIR=/sundry/etc-baks/`uname -r`-$date

no_bw=
no_bk=
no_etc=
rcs_etc=
clean_up_old_logs=


# see the man page of getopt for inadequacies.
args=` getopt wkecr $* `

[ $? != 0 ] && {
    echo 1>&2 'Getopt failed.'
    exit 2
}

set -- $args
for i in $*
do
    case $1 in
	-w) no_bw=echo;;
	-k) no_bk=echo;;
	-e) no_etc=echo;;
	-r) no_etc=''; rcs_etc=yes;; # rcs instead of copy.
	-c) clean_up_old_logs=y;;
	--) shift; break;;
	*) 
	    echo 1>&2 "Unsupported option>$1<";
	    exit 1 ;;
    esac
    shift
done

if [ -n "$clean_up_old_logs" ]
then
    rm -f ${bw_log_base}*
    rm -f ${bk_log_base}*
    rm -f ${bwk_log_base}*
fi

if [ -z "$no_etc" ]
then
    mkdir -p $ETC_BAK_DIR || {
	echo > $bwk_log mkdir of etc backup dir failed.
	exit 2
    }
    cp -RpP /etc $ETC_BAK_DIR  || {
        echo > $bwk_log cp of etc backup dir failed.
        exit 2
    }
fi

if [ -n "$rcs_etc" ]
then
    rcsetc || {
	echo > $bwk_log rcsetc failed.
	exit 2
    }
fi

if USER=theoden $no_bw make buildworld  "$BWF" > $bw_log 2>&1 && \
   USER=theoden $no_bk make buildkernel $BKF > $bk_log 2>&1
then
    date > $bwk_log
    echo "bwk completed successfully" >> $bwk_log
else
    status=$?
    date > $bwk_log
    echo "bwk failed: $status" >> $bwk_log
fi

