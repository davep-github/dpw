#!/usr/bin/env perl
#
# $Id: cc-defs-to-def_strings.pl,v 1.1 2002/06/03 17:05:37 davep Exp $
#
# make a nice, pretty comment by wrapping lines if they get too long.
# 
$comment_line_max = 70;
sub print_comment
{
    my $text;
    my $line;
    my $text;
    my $word;

    ($text) = @_;
    @text = split(/ /, $text);

    print "/*\n";
    print "*" x 72, "\n";
    print "*\n";

    $line = '';
    while (@text) {
	$word = shift(@text);
	#print "word>$word<\n";
	# handle pathological word lengths
	if (length($word) > $comment_line_max) {
	    print "*$line\n" if (length($line) > 0);
	    print "* $word";
	    $line = '';
	}
	elsif (length($line) + length($word) > $comment_line_max) {
	    print "*$line\n" if (length($line) > 0);
	    $line = " $word";
	}
	else {
	    $line = "$line $word";
	    #print "line>$line<\n";
	}
    }

    print "*$line\n" if (! $line eq "");

    print "*\n";
    print "*" x 72, "\n";
    print "*/\n";
}

#
# standard dire warning...
#
print_comment("This is a generated file.  Editing it will do you very little good in the long run, so just LEAVE IT ALONE!");

print "char* tm_def_strings[] =\n{\n";

$sep = "";

while (<>) {
    chop;

    @defs = split(/ /, $_);

    #
    # puts -Ds first, sorted, 
    # followed by -Us, also sorted.
    #
    foreach $def (sort(@defs)) {
	#print ">$def<\n";
	($ud, $val) = $def =~ /(-[UD])(.*)$/;
	if ($val =~ /=/) {
	    ($defval) = $val =~ /(.*)=(.*)/;
	}
	else {
	    $defval = $val;
	}

	print "$sep#ifdef $defval\n";
	print "   \"-D\"\n";
	print "#else\n";
	print "   \"-U\"\n";
	print "#endif\n";
	print "   \"$val\"";
	$sep = ",\n\n";
    }
}

print "\n};\n";
print "\n";
print "#define	NUM_DEF_STRINGS	(DIM(tm_def_strings))\n";

