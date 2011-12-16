#!/usr/bin/env perl

print "ARGV>@ARGV<\n";
$remote_executor = "ssh";
$orq = "'";
$crq = "'";
$host = shift @ARGV;
print "host>$host<\n";
# ssh <our args as a string>
$argv_str = join " ", @ARGV;
print "argv_str>@argv_str<\n";
$cmd = sprintf("%s %s %s%s%s", $remote_executor, $host, $orq, $argv_str, $crq);
print "cmd>$cmd<\n";
system($cmd);
echo
