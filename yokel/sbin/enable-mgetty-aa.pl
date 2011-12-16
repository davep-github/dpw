#!/usr/local/bin/perl -U

die "No tty specified" if (!$ARGV[0]);
$cfile = "/etc/nologin.$ARGV[0]";
$prog=`basename $0`;
chop $prog;
#print "prog>$prog<\n";
if ($prog =~ /^enable/)
{
	print "enabling\n";
	if (-f $cfile)
	{
	    if (unlink "$cfile" != 1)
		{
		die "unlink failed: $!\n";
		}
	}
}
elsif ($prog =~ /^disable/)
{
	print "disabling\n";
	if (! -f $cfile)
	{
	    open(TMP, ">$cfile") || die "open failed.\n";
	    close(TMP);
	}
}
