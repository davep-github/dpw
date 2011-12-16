#!/usr/bin/env perl

##########################################################################
#
# $Id: CVS-log.pl,v 1.1 2003/04/18 17:23:42 davep Exp $
#
# log.pl [-a] [-l logfile] [-n] [-m mail-list] [args...]
#
# mail-list is a file which contains a list of names to be notified
#  of the new log info.
# Args are args passed by cvs.  We will just echo them to the
#  mail message.
# If -a is specified, then send to all users in the maillist.  By default,
#  the committer is excluded from the mailing.
#
# This script takes the specifed args and builds a mail message to everyone
#  on the mail-list.
# It also will optionally add the loginfo to a logfile.
# 
#
# CVS requires that this filter read stdin till EOF, otherwise it may
#  receive a broken pipe signal
#
@mailer_list = ("/usr/ucb/mailx", "/usr/bin/mailx", "/bin/mail");

#
# flags that says to mail to all users, even the committer.
#
$allflag = 0;

#
# log file name for the commit log file
#
undef $logfile;

#
# test flag... just show what we would do.
#
undef $test;

#
# holds name of people to be notified
#
undef $mail_list_file;
#
# parsess argses...
#
while (($opt) = ($ARGV[0] =~ /^-(.)/)) {
    if ($opt eq "a") {
	$allflag = 1;
    }
    elsif ($opt eq "l") {
	$logfile = $ARGV[1];
	shift(@ARGV);
    }
    elsif ($opt eq "n") {
	$test = 1;
    }
    elsif ($opt eq "m") {
	$mail_list_file = $ARGV[1];
	shift(@ARGV);
    }

    shift(@ARGV);
    last if ($opt eq "-");
}

$user = `whoami`;
chop($user);
undef %mail_list;
$dashes="=" x 77;

#$commit_list = ">" . join("<\n>", @ARGV) . "<\n";
undef $commit_list;
foreach $arg (@ARGV) {
    $commit_list .= join("\n  ", split(' ', $arg)) . "\n";
}

#
# CVS will start this program as a filter and will write log
# information to it.  If this process goes away before CVS is done,
# then we get a broken pipe signal.
# Therefor we need to read and discard input until EOF
# if exiting abnormally
#
sub bagit
{
    warn join(' ', @_) if @_;

    while (<STDIN>) {}
    exit 0;
}

#
# read the mail list file and construct a list of recipients.
# If -a is not specified, exclude the current user from the list.
#

# print "mail_list_file>$mail_list_file<\n" if $test;

if ($mail_list_file) {
    open(ML, "<$mail_list_file") or &bagit("canna open $mail_list_file: $!");
    while (<ML>) {
	# print "_>$_<\n" if $test;
	chop;
	next if /\s*#/;
	foreach $name (split) {
	    # print "name>$name<\n" if $test;
	    next if !$allflag && $name =~ /^$user$/;
	    #
	    # use a hash to keep each name in the list unique
	    #
	    # push @mail_list, $name;
	    $mail_list{$name} = 1;
	}
    }
    close(ML);
}

if ($test) {
    print "maillist>>";
    print join("<\n>", keys(mail_list)) . "<<\n";
}

#
# allow empty maillist since we may be logging to a file, too.
#

if (%mail_list) {
    #
    # find the mailer to use.
    #
    # DUNIX mail has no -s option.  mailx does.
    # Linux has no mailx, but has a mail with a -s option.
    # this order should work on DUNIX and Linux
    #
    undef $mailer;
    foreach $m (@mailer_list) {
	if ( -x $m) {
	    $mailer = $m;
	    last;
	}
    }
    bagit("Canna find mail program") if (! $mailer);
    
    #
    # build the mail command
    #
    $mail_proc = "$mailer -s \"cvs update\" " . join(' ', keys(mail_list));
}
else {
    print "No mail_list\n" if $test;
    undef $mail_proc;
}

if ($test) {
    print "mail_proc>$mail_proc<\n";
    $mail_proc = "cat";		# for testing
}

#
# open the mail command as the end of a pipe so we can write
# to it.
#
if ($mail_proc) {
    open(MAIL_PROC, "|$mail_proc") or &bagit;
}

#
# open the log file for concatenation
if ($logfile) {
    open(LOG, ">>$logfile") or &bagit;
}

#
# put the line into the appropriate place[s]
#
sub logline
{
    print MAIL_PROC @_ if ($mail_proc);
    print LOG @_ if ($logfile);
}

#
# write the header information
#
&logline("$dashes\n");
&logline("Update by $user\n");
&logline(`date`);
&logline($commit_list);
&logline("$dashes\n");

#
# copy stdin to the mail process
#
while (<STDIN>) {
    &logline($_);
}

close(MAIL_PROC) if ($mail_proc);
close(LOG) if ($logfile);

#
# that's all folks.
#
exit(0);
