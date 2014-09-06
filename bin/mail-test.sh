#!/bin/bash
# $Id: mail-test.sh,v 1.14 2005/05/04 08:20:11 davep Exp $
#
#set -x

: ${zzz:=$(( 60 * 60 * 9 ))}

# all domain mailboxes forward to the speakez email address.
speakez='dpanariti@speakeasy.net'
verizon='panariti@verizon.net'
other_adders="$verizon"

CC="$verizon"

names='catch-allXXX davep nobdy davep.mail-test'
domains='meduseld.net
crickhollow.org
withywindle.org
the-last-alliance.org'

addrs=''
for name in $names
  do
  for domain in $domains
    do
    addrs="$addrs $name@$domain"
  done
done

addrs="$addrs $other_adders"

: ${num:=0}

for sig in 2 3 4 5 6 7 8 15
  do
  trap "echo ; echo $0: Got sig $sig, exiting.; exit $sig" $sig
done

while :; do
    for dest in $addrs; do
        subject="${num}: getmail/Maildir test"
        mail_cmd="mail -s \"$subject\" -c $CC $dest"
        msg="${num}: mail for: $dest

mail command: >$mail_cmd<"
        
        echo "msg>${msg}<"
        
        # cc everything to forwarded addr, since the domain forwarders drop
        # shit way too often.
        date
        echo "${msg}" | \
            eval $mail_cmd
        echo "sleep for $zzz"
        sleep $zzz
        num=$(( $num + 1 ))
    done
done



