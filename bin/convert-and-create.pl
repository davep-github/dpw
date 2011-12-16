#! /usr/bin/perl
# put into the public domain by Russell Nelson <nelson@qmail.org>
# NO GUARANTEE AT ALL; support is available for a fee from the author.
#
# Creates maildirs for everyone in /etc/passwd who receives mail.
# Copies all their mail in /var/spool/mail into their maildir.
# Assumes that nothing is trying to modify the mailboxes in /var/spool/mail
#   This assumption could be removed by locking the mailboxes and deleting
#   the mail after moving it.
# version 0.00 - first release to the public.

while(($name, $passwd, $uid, $gid, $quota, $comment, $gcos, $dir, $shell) =
      getpwent()) {
    if (!-e $dir) {
	print "warning: ${name}'s home dir, $dir, doesn't exist (passwd: $passwd), skipping.\n";
	next;
    }
    $st_uid = (stat($dir))[4];;
    if ($uid != $st_uid) {
	print "warning: $name is $uid, but $dir is owned by $st_uid, skipping.\n";
	next;
    }
    print "$name\n";
    $spoolname = "$dir/Maildir";
    -d $spoolname || mkdir $spoolname,0700 || die "fatal: mailbox doesn't exist and can't be created.\n";
    chown ($uid,$gid,$spoolname);
    chdir($spoolname) || die("fatal: unable to chdir to $spoolname.\n");
    -d "tmp" || mkdir("tmp",0700) || die("fatal: unable to make tmp/ subdir\n");
    -d "new" || mkdir("new",0700) || die("fatal: unable to make new/ subdir\n");
    -d "cur" || mkdir("cur",0700) || die("fatal: unable to make cur/ subdir\n");
    chown ($uid,$gid,"tmp","new","cur");

    open(SPOOL, "</var/spool/mail/$name") || next;
    $i = time;
    while(<SPOOL>) {
        if (/^From /) {
            $fn = sprintf("new/%d.$$.mbox", $i);
            open(OUT, ">$fn") || die("fatal: unable to create new message");;
            chown ($uid,$gid,$fn);
            $i++;
            next;
        }
	s/^>From /From /;
	print OUT || die("fatal: unable to write to new message");
    }
    close(SPOOL);
    close(OUT);
}
endpwent();
