#!/bin/bash
# $Id: mew-inc.sh,v 1.2 2004/12/31 09:20:04 davep Exp $
#
set -x
LOG="$DP_LOG/mew/mew-inc.sh.log"

echo "================================" >> $LOG
date >> $LOG

(
mew-inc-maildir.sh || {
    echo 1>&2 "mew-inc-maildir.sh failed."
    exit 1
}

mew-inc-mbox.sh "$@" || {
    echo 1>&2 "mew-inc-mbox.sh failed."
    exit 1
}

echo "============(0: DONE)==============" >> $LOG

exit 0

) 2>> $LOG

echo "=============1: DONE===============" >> $LOG

exit 0

