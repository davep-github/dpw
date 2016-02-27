# getmailrc -- getmail configuration file
# $Id: getmailrc-old-3.x,v 1.1 2012/01/08 18:28:20 root Exp $
#
[default]
#postmaster = /var/mail/getmail-postmaster
#postmaster = "|/usr/bin/getmail_mbox /var/mail/davep"
postmaster = "~davep/Maildir/"

#delete_after = 1
readall = 1
delete = 1
message_log = /var/log/getmail
# causes warning
#use_apop = 1
eliminate_duplicates = 0
timeout = 60

########################################################################
[Speakeasy]
server = mail.speakeasy.net
username = dpanariti
password = '&U&Ixover'
envelope_recipient = 'Delivered-To:2' #   recipient addresses

# we need a default entry to handle email directly to the speakeasy accounts
# since the Delivered-To: headers are different in direct vs forwarded
# (i.e. the domain forwarding) messages.
# Using postmaster as default requires my patches to getmail.
#postmaster = "|/usr/bin/getmail_mbox /var/mail/davep"
postmaster = "~davep/Maildir/"

# Susan gets Robbie's mail till Robbie is old enough.
local = "^(susan|rob|robin|robbie|nemo|barkk?a).*@.*$,~susan/Maildir/"

local = "(davep|dpanariti|chicxulub).*@.*$,~davep/Maildir/"

local = "^(all|everyone|family|panaritis|everybody)@.*$,~davep/Maildir/"
local = "^(all|everyone|family|panaritis|everybody)@.*$,~susan/Maildir/"

# for testing
local = theoden@meduseld.net,/var/mail/theoden
local = mail-test@.*,~mail-test/Maildir/

# some mailing list stuff comes addressed to the group.
# this prevents spurious delivered to postmaster messages.
local = ".*@.*(freebsd|xemacs).org,~davep/Maildir/"

########################################################################
[Speakeasy2]
server = mail.speakeasy.net
username = chicxulub
password = 'Ra1n0rsl33t'
postmaster = "|/usr/bin/getmail_mbox /var/mail/davep"
envelope_recipient = 'Delivered-To:1' #   recipient addresses
local = "chicxulub.*@.*$,|/usr/bin/getmail_mbox /var/mail/davep"

########################################################################
#[Meduseld]
#server = mail.attbi.com
#server = mail.comcast.net
#username = meduseld
#password = Ra1n0rsl33t
#envelope_recipient = 'Delivered-To:1' #   recipient addresses
#postmaster = "|/usr/bin/getmail_mbox /var/mail/davep"
#
## Susan get Robbie's mail till Robbie is old enough.
#local = "susan.*@.*$,|/usr/bin/getmail_mbox /var/mail/susan"
#local = "rob.*@.*$,|/usr/bin/getmail_mbox /var/mail/susan"
#local = "nemo.*@.*$,|/usr/bin/getmail_mbox /var/mail/susan"
#local = "barkk?a.*@.*$,|/usr/bin/getmail_mbox /var/mail/susan"
#
#local = "davep.*@.*$,|/usr/bin/getmail_mbox /var/mail/davep"
#local = "dpanariti@.*$,|/usr/bin/getmail_mbox /var/mail/davep"
#
#local = "panariti@attbi.com,|/usr/bin/getmail_mbox /var/mail/davep"
#
## for testing
#local = theoden@meduseld.net,/var/mail/theoden
#
## some mailing list stuff comes addressed to the group.
## this prevents spurious delivered to postmaster messages.
#local = ".*@.*freebsd.org,|/usr/bin/getmail_mbox /var/mail/davep"
#local = ".*@.*xemacs.org,|/usr/bin/getmail_mbox /var/mail/davep"
#
#
#########################################################################
#[davep]
#server = mail.comcast.net
#username = panariti
#password = Ra1n0rsl33t
#postmaster = "|/usr/bin/getmail_mbox /var/mail/davep"
#
#########################################################################
#[Susan]
#server = mail.comcast.net
#username = susan.panariti
#password = Ra1n0rsl33t
#postmaster = "|/usr/bin/getmail_mbox /var/mail/susan"
