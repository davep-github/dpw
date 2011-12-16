#!/usr/bin/env perl

print "ARGV>", join('+', @ARGV), "<\n";

if ($ARGV[0] =~ /^-p(.*)/)
{
print "1>$1<\n";
   shift;
   $path = ($1 ? $1 : shift);
}
else
{
   $path = $ENV{"Path"};
}

@spath = split(/;/, $path);
print "path>$path<\nspath>@spath<\n";

foreach $arg (@ARGV)
{
#   print "arg>$arg<\n";
   $header = 1;
   foreach $dir (@spath)
   {
      $pat = "$dir/$arg";
      $pat =~ s!/+!\\!g;
      $pat =~ s!\\+!\\!g;
#      print "pat>$pat<\n";
      while (<${pat}>)
      {
         #print "$dir:\n" if $header;
         $header = 0;
         print "$_\n";
      }
   }
}
