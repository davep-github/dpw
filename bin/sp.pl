#!/usr/bin/perl
require 'getopts.pl';

&Getopts('1V:v');
#print "opt_1>$opt_1<\n";
#print "opt_V>$opt_v<\n";
$opt_V = 3 if ($opt_v && !$opt_V);

$hitPrefix = "    " if $opt_V;

#
# OS2 uppercases all env names.
# NT leaves 'em alone, but cmd treats 'em as case insenitive, and its path is
# "path", not "PATH"
#
$OSName = $ENV{'OSName'};
$OSName = $ENV{'OSNAME'} if (!$OSName);
$path = $ENV{'PATH'};
$path = $ENV{'path'} if (!$path);
$path = $ENV{'Path'} if (!$path);
#
# handle our diverse environments...
#
if (" dos os2 win nt " =~ / $OSName /i)
{
	$pathSep = ';';
	$nameSep = '\\';
	if (" os2 " =~ / $OSName /i)
	{
		@extList = ('.com', '.exe', '.cmd');
	}
	elsif (" nt " =~ / $OSName /i)
	{
		@extList = ('.com', '.exe', '.bat', '.cmd');
	}
	else
	{
		@extList = ('.com', '.exe', '.bat');
	}
	$test = "-f";
	$path = ".;" . $path;
#   print "path>$path<\n";
}
else
{
	$pathSep = ':';
	$extList = ("");
	$nameSep = '/';
	$test = "-x";
}
#print "pathSep>$pathSep<, OSName>$OSName<, path>$path<\n";

$testCmd = "$test \$targ";
foreach $pathEl (split(/$pathSep/, $path))
{
	# perl (and bash!) cannot handle a ~ in a command like:
	# -x ~/bin/blah
	# they don't see it as executable,
	# we xlat it via echo so we don't have to worry about stuff like
	# ~davep
	# 
	chop($pathEl = `echo $pathEl`) if $pathEl =~ /~/;
	push(@path, $pathEl);
}
#print "path>$path<\n";
foreach $arg (@ARGV)
{
	foreach $pathEl (@path)
	{
      if ($pathEl =~ /\\$/)
      {
#        print "chopping???!!!\n";
         chop($pathEl);
      }
		print "$pathEl\n" if ($opt_V & 0x2);

		foreach $ext (@extList)
		{
#			print "ext>$ext<\n";
			$targ="$pathEl$nameSep$arg$ext";
         print "  try: $targ\n" if ($opt_V & 0x1);
         if (eval $testCmd)
			{
				print "$hitPrefix$targ\n";
				exit 0 if $opt_1;
			}
		}
	}
}
	
