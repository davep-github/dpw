#!/bin/bash
# $Id: mew-inc-maildir.sh,v 1.1 2004/12/31 09:20:04 davep Exp $
#
set -x

: ${MEW_INBOX:=~/MH/inbox}

cd $MEW_INBOX || {
    echo 1>&2 "cannot cd to inbox>$MEW_INBOX<"
    exit 1
}

incm -a -d ~davep/Maildir

exit $?
