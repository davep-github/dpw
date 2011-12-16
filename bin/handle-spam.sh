#!/bin/sh
#set -x
# $Id: handle-spam.sh,v 1.4 2004/03/08 09:20:06 davep Exp $
#
# mew/procmail puts spam in the spamcan folder to be handled by us
#
# 1. forward and rmm messages already identified by spamassassin as spam
#    (ie *****SPAM:nn.nn***** in subject)
# 2. study remaining.
# 3. forward and rmm remaining uce@ftc.gov

. eexec

if [ "$1" = "-n" ]
then
    EExecDashN '+'
    dash_n='-n'
    shift
else
    dash_n=''
fi

EExecVerbose

forward_and_rmm()
{
    for msg in "$@"
    do
	# there's gotta be a better way!
	echo "forw: $msg"
	echo 'send' | forw +spamcan -form spam-forwcomps -noedit $msg
	sleep 2
    done
    rmm "$@"
}

if msglist=`pick +spamcan -sub '\*\*\*SPAM:'`
then
    EExec forward_and_rmm $msglist
fi

#
# only hand picked spam left (no ***SPAM... indicator)
#
# 2. study remaining spam
# 3. forward it to uce@ftc.gov
# spam-filterfile will hold dest addr (uce@ftc.gov)

# all remaining messages
if msglist=`pick +spamcan`
then
    if [ -n "$study_spam" ]
    then
	# asshole spammers are using series of random words to confuse spam
	# analyzers.  but they are rarely punctuated properly... look for
	# exceptionally long lines?
	echo "study spam:"
	EExec study-spam $dash_n -k -m spamcan
    else
	echo "not studying spam"
    fi
    echo "forward remaining:"
    EExec forward_and_rmm $msglist
fi

exit 0

