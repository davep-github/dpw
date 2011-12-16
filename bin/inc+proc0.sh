#!/bin/sh
# $Id: inc+proc0.sh,v 1.1 2004/08/06 13:38:45 davep Exp $
#
# NB: mew gets grumpy if this script returns extraneous info
set -x
#
# Majority of this file copped from procmail manpage
#

#LOG="/tmp/inc+proc.sh.log"
#date >> $LOG
#echo "*>$*<" >> $LOG
#echo "HOME>$HOME<" >> $LOG
#env >> $LOG
#echo '--' >> $LOG

: ${USER:=davep}
: ${MAIL:=/var/mail/davep}
: ${keep_spool:=y}

# I use a param for testing from the command line, however
# mew sets $1 to the include into folder, so I must use
# $2 instead
if [ -n "$2" ]
then
    ORGMAIL=$2
    keep_spool=y
else
    ORGMAIL=$MAIL
    [[ "$keep_spool" != y ]] && keep_spool=n
fi

#echo "ORGMAIL>$ORGMAIL<" >> $LOG
#test -s $ORGMAIL
#echo "?>$?<" >> $LOG
SPOOL_BAK_NAME=procmail-unfiltered-spool
SPOOL_BAK_DIR=$DP_LOG/procmail
UNFILTERED_SPOOL_BAK=$SPOOL_BAK_DIR/$SPOOL_BAK_NAME

if cd $HOME &&
    test -s $ORGMAIL &&
    lockfile -r0 -l30 .newmail.lock 2>/dev/null
then
    # @todo guarantee uniqueness ???
    #LOGFILE="/tmp/inc+proc.sh_$$"; export LOGFILE
    #LOGABSTRACT=all; export LOGABSTRACT
    trap "rm -f .newmail.lock $LOGFILE" 1 2 3 13 15
    umask 077
    lockfile -l30 -ml
    # paranoia backup
    # bak files are rotated w/newsyslog
    {
        echo "================= $(date) ================="
        cat $ORGMAIL
    } >> $UNFILTERED_SPOOL_BAK

    cat $ORGMAIL >> .newmail && [ "$keep_spool" != 'y' ] &&
	cat /dev/null >$ORGMAIL
    lockfile -mu
    # supercite.el dislikes `From ' lines (non-RFC822). This renames
    # them to proper form.  -R changes the fieldname, -z ensures a
    # blank follows the fld name.
    formail -R 'From ' 'X-Old-From:' -z -s procmail $INC_PROC_RC < .newmail &&
	rm -f .newmail
    # emit message numbers so mew knows what has just arrived.
    # ~/.procmail_logfile is used in procmailrc and tells where the
    # log info goes.
    sed -n 's!Folder:[^/][^/]*/\([0-9]*\).*[0-9][0-9]*!\1!p' \
	$HOME/MH/procmail_logfile
    
    # now remove logfile so we don't get mail twice.
    > $HOME/MH/procmail_logfile
    #rm -f $LOGFILE
    rm -f .newmail.lock
fi
exit 0
