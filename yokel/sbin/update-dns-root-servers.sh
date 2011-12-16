#!/bin/sh
#
# Update the nameserver cache information file once per month.
# This is run automatically by a cron entry.
#
# Original by Al Longyear
# Updated for bind 8 by Nicolai Langfeldt
# Miscelanious error-conditions reported by David A. Ranch
# Ping test suggested by Martin Foster
#
(
 # another (currently down) server: rs.internic.net
 ROOT_SERVER=K.ROOT-SERVERS.NET
 PING_HOST=bos.speakeasy.net
 ROOT_FILE=named.root
 ROOT_FILE_NEW=${ROOT_FILE}.new
 ROOT_FILE_OLD=${ROOT_FILE}.old
 PATH=/sbin:/usr/sbin:/bin:/usr/bin:
 export PATH
 cd /etc/namedb

 echo "To: hostmaster <hostmaster>"
 echo "From: system <root>"
 echo "Subject: Automatic update of the ${ROOT_FILE} file"
 echo

 # Are we online?  Ping a server at your ISP
 case `ping -qnc 1 ${PING_HOST}` in
   *'100% packet loss'*)
        echo "The network is DOWN. ${ROOT_FILE} NOT updated"
        echo
        exit 0
        ;;
 esac

 dig @${ROOT_SERVER} . ns >${ROOT_FILE_NEW} 2>&1

 case `cat ${ROOT_FILE_NEW}` in
   *NOERROR*)
        # It worked
        :;;
   *)
        echo "The ${ROOT_FILE} file update has FAILED."
        echo "This is the dig output reported:"
        echo
        cat ${ROOT_FILE_NEW}
        exit 0
        ;;
 esac

 echo "The ${ROOT_FILE} file has been updated to contain the following   
information:"
 echo
 cat ${ROOT_FILE_NEW}

 chown root ${ROOT_FILE} ${ROOT_FILE_NEW} 
 chmod 444 ${ROOT_FILE_NEW} 
 rm -f ${ROOT_FILE_OLD} 
 mv ${ROOT_FILE} ${ROOT_FILE_OLD}
 mv ${ROOT_FILE_NEW} ${ROOT_FILE}
 ndc restart
 echo
 echo "The nameserver has been restarted to ensure that the update is complete."
 echo "The previous ${ROOT_FILE} file is now called   
/etc/namedb/${ROOT_FILE_OLD}."
) 2>&1 | /usr/sbin/sendmail -t
exit 0