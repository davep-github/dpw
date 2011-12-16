#!/usr/local/bin/perl

$ARGV[0] =~ s!.*/!!;

# get base of script name
$prog = $0;
$prog =~ s!.*/!!;
