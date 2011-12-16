#!/usr/bin/perl 
# 
# qmailconvert
# based on mbox2maildir.pl that was
# put into the public domain by Bruce Guenter <bruceg@qcc.sk.ca>,
# which was, in turn, 
# based heavily on code by Russell Nelson <nelson@qmail.org>, also in
# the public domain
# 
# by todd underwood (todd@nm.net) and monte mitzelfeld (monte@nm.net)
#
# Impovements include:
# Store old mboxes in oldmbox/, better command line options handling
# changed file naming to match dan bernstein's naming criteria. 
# Now does:  just a file, just a directory or all
# (which is inbox (/var/spool/mail by default) and a directory (~/home) by
# default.
#
# NO GUARANTEES AT ALL IN LIFE
#
# Creates maildirs from mailboxes
# Assumes that nothing is trying to modify the mailboxes
# version 0.00 - first release.
# version 0.01 - fixed:  ok to have an empty mailbox, skips received.log in 
#                        mboxdir (for procmail), creates full paths for 
#                        directories 
# version 0.02 - added:  creates .qmail files with $target (default 
#                        $home . /Maildir/) in it for correct delivery
#

use Getopt::Long;		# This is for option handling
use Sys::Hostname;		# This is for easy hostnames
use File::Basename;		# For easy parsing of filenames
use File::Copy;			# For easy file backups
require 'stat.pl';

# print usage if no arguments
&usage(1) unless @ARGV;

# create the hash to pass into the GetOptions function
%optctl = ("help" => \$help,
	   "inbox" => \$inbox,
	   "target" => \$target,
	   "directory" => \$mboxdir,
	   "mboxdir" => \$mboxdir,
	   "uid" => \$uid,
	   "username" => \$username,
	   "gid" => \$gid,
	   "groupname" => \$groupname,
	   "all" => \$all,
	   "file" => \$file);
# get the options.  put them into the hash.  ! means bool and can be --no<opt>
# :s means optional string, :i means optional integer
GetOptions(\%optctl, 
	   "help!", 
	   "inbox:s", 
	   "directory:s",
	   "target:s", 
	   "mboxdir:s",
	   "uid:s",
	   "username:s",
	   "gid:s",
	   "groupname:s",
	   "all!",
	   "file:s"); 

# print usage if -h is defined (if user typed --help it will be)
&usage(1) if defined($help);

# change $username,$groupname to numeric
if (defined($username)){
    $uid = getpwnam($username);
}
else {
    # otherwise set to current user
    $uid = $> unless defined $uid ;
    if ( $uid == 0 ) {
	error("qmailconvert should not be run for root.\n\tPlease specify a user with -user or -uid.");
    }
}
if (defined($groupname)){
    $gid = getgrnam($groupname);
    if ( $gid == 0){
	print("Are you sure you want to use gid '$gid' which is group '$groupname'?  ");
	$_ = <STDIN>;
	error("Exiting.  Please try again with -group or -gid specified.") unless ( /^y|Y/ );
    }
}
else{
    # otherwise set to primary group of current user
    $gid = (getpwuid($uid))[3] unless defined $gid ;
}
# set other defaults
# $homedir is the home directory of the user we're converting
$homedir = (getpwuid($uid))[7];

# $target is either defined or it's $homedir/Maildir/
defined($target) or
    ((defined($file)) and ($target="$file")) or 
    $target = $homedir . "/Maildir/";

# either we're doing one file, or we've already set $inbox
# or we get /var/spool/mail/username
defined($file) or 
    ( $inbox ) or 
    ( ! defined($inbox) ) or
    $inbox = "/var/spool/mail/" . (getpwuid($uid))[0];

# set mboxdir if it's not set and $file is not set
defined($file) or 
    ( $mboxdir ) or
    ( ! defined($mboxdir)) or 
    $mboxdir = (getpwuid($uid))[7] . "/mail/";
# make mboxdir in long form so can chdir to it (asume home directory,
# not current directory. add full path to it unless it's already full.
if ( defined($mboxdir) ){
    $mboxdir = "$homedir/$mboxdir" unless ($mboxdir =~ qq!^/.*!);
}

# if $file then we're converting one file, just do it.
if (defined($file)){
    copy($file,$file.$$)
	or error("Can't copy $file to $file.$$");
    unlink($file) or error("Can't delete $file");
    $file = $file.$$;
    # target should always be defined, but just in case...  
    if (defined($target)){
	convert($file,$target);
    }
}


# if $inbox we're converting the inbox.  
# don't add it to the list, but just convert it right here
# because there are several special things about it and this makes it
# easier.
if(defined($inbox)){
    if (-f $inbox){
	# make inbox in long form so can chdir to it (asume home
	# directory,
	# not current directory.
	$inbox = "$homedir/$inbox" unless ($inbox =~ qq!^/.*!); $inshort =
	    basename($inbox); -d "$homedir/oldinbox" or
		mkdir("$homedir/oldinbox",0700)
		    or error("$homedir/oldinbox doesn't exist and couldn't be created.\n");
	chown ($uid,$gid,$homedir . "/oldinbox") if defined($uid) &&
	    defined($gid)
		or error ("Can't chown $homedir/oldinbox to uid $uid and gid $gid.");
	copy($inbox,$homedir."/oldinbox/" . $inshort)
	    or error("Can't copy $inbox to $homedir/oldinbox/$inshort");
	unlink($inbox) or error("Can't delete $inbox");
	$inbox = $homedir . "/oldinbox/" . $inshort; 
	# target should always be defined, but just in case...  
	if (defined($target)){
	    convert($inbox,$target);
	}
    }
    else {
	chdir $homedir or error("Can't change to $homedir");
	mkdir("$target",0700) || error ("unable to make $target");
	chdir $target or error("Can't change to $target");
	-d "tmp" || mkdir("tmp",0700) || error("unable to make tmp/ subdir");
	-d "new" || mkdir("new",0700) || error("unable to make new/ subdir");
	-d "cur" || mkdir("cur",0700) || error("unable to make cur/ subdir");
	chown ($uid,$gid,"tmp","new","cur") if defined($uid) && defined($gid);
    }
} # end if defined inbox

# create a list of files to convert
if(defined($mboxdir)){    
    print "mboxdir is $mboxdir\n";
    unless ( opendir(DIR,$mboxdir) ){
	warn("Can't open directory '$mboxdir'");
    }
    else {
	push @filelist, readdir(DIR);
	closedir(DIR) or error("Can't close directory '$mboxdir'");;

	###########################
	# loop through the files on the list and convert
	# them, making backups in a directory named 'oldmbox'
	# in the directory they are in, if we are converting 
	# i.e., if $mboxdir is set.
	###########################

	foreach $filename ( @filelist ){
	    # skip the standard procmail received log
	    next if ($filename eq "received.log");
	    chdir $mboxdir or 
		error("Can't change to directory $mboxdir");
	    next if ( -d $filename );	# skip over all directories
	    -d "oldmbox" or mkdir oldmbox,0700 or 
		error("oldmbox directory doesn't exist in $mboxdir and can't create it.");
	    copy($filename, "oldmbox/$filename") or
		error("Can't copy $filename to oldmbox/$filename");
	    unlink($filename) or
		error("Can't delete $filename");
	    convert("oldmbox/$filename",$filename);
	} # end foreach

	# now clean up by fixing permissions in oldmbox/ directory
	chdir($mboxdir . "/oldmbox/") or 
	    error("Can't change to directory $mboxdir/oldmbox/");
	opendir(DIR,".");
	@filelist = readdir(DIR);
	chown ($uid,$gid,@filelist) if defined($uid) && defined($gid);
	closedir(DIR);
    } # end else opendir
} # end if defined($mboxdir)


##########################
# Set up a simple .qmail in the
# user's directory so that mail can 
# be delivered properly
##########################
chdir($homedir) or
    error("Can't change to directory $homedir");
# leave the .qmail file alone if it already exists
if (! -f ".qmail") {
    if ( -f ".forward"){
	open(IN,"<.forward") || error("Can't open .forward file: $!");
	open(OUT,">.qmail") || error("Can't open .qmail file: $!");
	# get first line of .forward
	$forward = <IN>;
        chomp $forward ;
	# find the 'bad' characters that mean we should *not* treat
	# this as a regular .forward
	# we're *not* dealing with complicated stuff.  we're bailing at this 
	# point.  if someone else wants to write the code to deal with this,
	# they can.  should handle:
	#            '#' for comments
	#            '"' for quotes (full name)
	#            '|' changed to 'preline'
	#            
	if ( $forward && length( $forward ) == $forward =~ tr/-A-Za-z0-9@.// ) {
	    if ($forward =~ tr/@//){
		print OUT "&$forward\n";
	    }
	    else{
		print OUT "&$forward\@nm.net\n";
	    }
	}
	close OUT || error("Can't close .qmail file");
	close IN || error("Can't close .forward file");
    }
}


# now regardless of anything, chown and chmod the .qmail
# since that's a constant source of problems.
chown ($uid,$gid,".qmail") if defined($uid) && defined($gid);
chmod (0600,".qmail");
# fix home directory permissions problems
chown ($uid,$gid,".") if defined($uid) && defined($gid);
# no obvious way to do this without a system call...
# could 'stat' then mask, then chmod and all that shit, but this
# is so much prettier (and slower, and less secure...)
system("chmod go-w .");



##########################
# accepts a file and a maildir name and 
# converts the file into the maildir
##########################
sub convert {
    print("sourcefile = $sourcefile, targetmaildir = $targetmaildir\n");
    ($sourcefile, $targetmaildir) = @_;
	-d $targetmaildir || mkdir $targetmaildir,0700 ||
	    &error("maildir '$targetmaildir' doesn't exist and can't be created.");
    &error("can't open mbox '$sourcefile'") unless
	open(SPOOL, $sourcefile);
    chown ($uid,$gid,$targetmaildir) if defined($uid) && defined($gid);
    chdir($targetmaildir) || &error("fatal: unable to chdir to $targetmaildir.");
    -d "tmp" || mkdir("tmp",0700) || &error("unable to make tmp/ subdir");
    -d "new" || mkdir("new",0700) || &error("unable to make new/ subdir");
    -d "cur" || mkdir("cur",0700) || &error("unable to make cur/ subdir");
    chown ($uid,$gid,"tmp","new","cur") if defined($uid) && defined($gid);
    
    $hostname = hostname() ;
    $i = 0 ;
    while(<SPOOL>) {
	if (/^From /) {
	    close(OUT);
	    $fn = sprintf("new/%09d.%d.%09d.%s", time, $$, $i++, $hostname );
	    open(OUT, ">$fn") || error("unable to create new message");
	    chown ($uid,$gid,$fn) if defined($uid) && defined($gid);
	    next;
	}
	s/^>From /From /;
	print OUT || &error("unable to write to new message");
    }
    close(SPOOL);
    close(OUT);
}


##########################
# prints an error message and quits
##########################
sub error {
    print STDERR join("\n", @_), "\n";
    exit(1);
}


##########################
# prints usage and quits
##########################
sub usage {
    print(STDERR "usage: \tqmailconvert
         --help, -h Print this message
           Commands:
         --file,-f Convert only the listed file
         --inbox,-i <inbox file>:  defaults to /var/spool/mail
         --target,-t <target new Maildir>: defaults to $home/Maildir/
         --mboxdir,--directory,-m,-d <directory of mboxes to convert>:\n\t\t\tdefaults to \$home/mail/
         --uid,--username <uid or username to create Maildirs as>: \n\t\t\tdefaults to current
         --gid,--groups <gid or group to create Maildirs as>:\n\t\t\tdefaults to primary group of current user\n");
    exit(@_);
}

