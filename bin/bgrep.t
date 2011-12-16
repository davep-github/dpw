#!/usr/bin/env perl

if ($ARGV[0] eq "-s") {
  $to_stdout = 1;
  shift(ARGV);
}


$first = shift(ARGV);
$second = shift(ARGV);
$till_eof = 0;

#print "f>$first<\n";
#print "s>$second<\n";
$state = 0;
$num = 0;
$base = "out";
$sep = "";

$till_eof = 1 if ($second eq '$^' || $second eq '');

while (<>)
{
  if ($state == 0)
    {
      if (/$first/o)
	{
	  print $sep;
	  $state = 1;
	  if (!$to_stdout) {
	    $oname = sprintf("%s%04d", $base, $num);
	    $num++;
	    open (OUT0, ">$oname") || die "canna open $oname, $!";
	    $OUT = \*OUT0;
	    print STDERR "using oname>$oname<\n";
	  } else {
	    $OUT = \*STDOUT;
	    print STDERR "using stdout\n";
	  }
	  print $OUT $_;
	  next;
	}
    }
  if ($state == 1)
    {
      print $OUT $_; 
      if (!$till_eof && /$second/o)
	{
	  $state = 0;
	  close OUT0 if (!$to_stdout);
	  $sep = "###################################################\n\n";
	  #next
	}
    }
  if ($state == 2)
    {
      print $OUT $_; 
      if (/$second/o)
	{
	  $state = 3;
	  # close OUT;
	  next;
	}
    } 
  if ($state == 3)
    {
      print $OUT $_; 
      if (/$second/o)
	{
	  $state = 0;
	  close OUT0 if (!$to_stdout);
	}
    } 
}
