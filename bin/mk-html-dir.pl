#!/usr/bin/env perl
# $Id: mk-html-dir.pl,v 1.2 2002/02/16 17:52:02 davep Exp $
#
# Create a directory in html.  Make a link for each item in the
# specified directory
#
# prog [-f re] dir...

$filter = '.*';

while ($ARGV[0] =~ /^[\-]/)
{
    $_ = shift;
   
    if (/^[\/\-]f(.*)/)
    {
	$filter = ($1 ? $1 : shift);
    }
}

die "$0: No dir... specified" if (! @ARGV);

# /usr/local/etc/apache/httpd.conf:DocumentRoot /usr/local/www/data
$www_root = `grep \'^DocumentRoot\' /usr/local/etc/apache/httpd.conf` 
    or die "$0: Canna determine www_root\n";
chop $www_root;
($www_root) = $www_root =~ /^DocumentRoot\s+(\S+)$/;
die "$0: Canna determine www_root" if (!$www_root || $www_root eq "");

while (@ARGV) {
    $dir = shift;
    chdir $dir or die "$0: Canna cd to $dir: $!\n";
    open(DIR, "ls -1|") or die "$0: Canna open dir pipe on $dir: $!";
    $dir_str = `pwd`;
    ($dir_str) = $dir_str =~ /$www_root\/*(.*)/;
    $dir_str = "\$WWW_ROOT" if !$dir_str || $dir_str eq "";
    $dir_str = "Directory listing of " . $dir_str;

    print "<HTML>\n";
    print "<BODY>\n";
    print "<TITLE>\n$dir_str\n</TITLE>\n";
    print "<H2>\n$dir_str\n</H2>\n";

    print "<P>\n<P>\n\n";

    #<a href="pics/rwrap.jpg">what we got</a>
    while (<DIR>) {
	chop;
	next if ! -f $_;
	print "<a href=\"$_\">$_</a><br>\n" if /$filter/o;
    }

    printf "\n";
    print "</BODY>\n";
    print "</HTML>\n";

}
