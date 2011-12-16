#!/usr/bin/env perl
# $Id: camera-to-web.pl,v 1.1.1.1 2001/01/17 22:22:27 davep Exp $

$prog = $0;
$prog =~ s!.*/!!;

$just_print = 0;
$rotating = 0;
$angle = 0;
undef %rotate_list;
$scale_factor = '1/3';

if ($ARGV[0] =~ /^-[hH?]/) {
    $help = << "EOR"
$prog [-n] [-s scale] dest-dir [file|-R|-Rxx|-r file]...

Prepare digital camera files for web publication.
Scale files by 1/3 (default) and optionally rotate the files.

dest-dir Where to stick the files.
-n       Just print what would be done.
-s scale Set scale factor (e.g. 1/2) [default == 1/3]
-R       Change rotation for following files.  non-zero --> zero, zero --> 90
-Rxx     Set rotation to xx
-r file  Set rotation for file to 90

All files are processed and rotation is set.  If a filename appears both
with and without rotation, (the last) rotation wins.  
This makes it OK to specify rotations for a few files, and to speficy 
all the rest with '*'.

e.g.

$prog -R a b c -R *
-or-
$prog * -R a b c

Which will rotate a, b and c 90 degrees and leave the rest alone, even 
though a, b and c will be in the '*' expansion.
EOR
    ;

    print $help;
    exit 1;
}

while ($ARGV[0] =~ /^-([ns])/) {
    shift;
    if ($1 eq 'n') {
	$just_print = 1;
    }
    else {
	$scale_factor = shift;
    }
}
$dst = shift;

#
# process the file list.  Each file can be preceeded by a '-r' flag
# which means to rotate the image.
# In order to aid lazy typists, a file can me mentioned >1 times.  The -r
# flag always wins.  This way you can type -r a -r b -r c *
# a, b, and c will be rotated, even though they also appear due to the
# * without a -r flag.
# In addition, a -R[xx] flag can be given which sets the rotation for the
# for all following files, until another -R[xx] is seen.  If no [xx] is
# given, the the rotation is toggled between 90 and 0.  A -R after any
# -Rxx resets the rotation to 0.
#
while ($infile = shift) {
    if ($infile =~/^-R(\d*)/) {
	if ($1 ne "") {
	    $rotating = $1;
	}
	else {
	    # no angle given toggle state
	    $rotating = $rotating ? 0 : 90;
	}
	# print "new rotating>$rotating<\n";
	next;
    }
    if ($infile eq "-r" || $rotating) {
	$infile = shift if $infile eq "-r";
	#
	# infile may be a list, too, so split it:
	foreach $inf (split(/[, \t]/, $infile)) {
	    #print "inf1>$inf<\n";
	    $rotate_list{$inf} = $rotating;
	}
    }
    else {
	if (! $rotate_list{$infile}) {
	    #print "inf2>$infile<\n";
	    $rotate_list{$infile} = 0;
	}
    }
}

foreach $key (keys(%rotate_list)) {
    #print "key>$key<\n";
    $infile = $key;
    $key =~ s!.*/!!;
    $outfile = "$dst/" . lc $key;
    #print "outfile>$outfile<\n";

    if ($rotate_list{$infile}) {
	$rot = "pnmrotate $rotate_list{$infile} |";
    }
    else {
	$rot = "";
    }

    $cvt_cmd = "djpeg -pnm -scale $scale_factor " . 
	"$infile | $rot cjpeg > $outfile";
    print "system($cvt_cmd)\n";
    system($cvt_cmd) if (!$just_print);
}
