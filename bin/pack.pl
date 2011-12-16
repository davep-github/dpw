#!/usr/bin/env perl

$template = $ARGV[0];
shift;
@list = @ARGV;

print STDERR "template>$template<, list>", join(", ", @list), "<\n";

$x = pack $template, @list;
print "$x";

exit $?;

