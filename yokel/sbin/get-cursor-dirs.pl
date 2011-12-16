#!/usr/bin/env perl


#my @THEMES = ("core", "redglass", "whiteglass");
#my @DESCS = ("standard black with white border cursor theme", "semi-transparent red cursor theme", "semi-transparent white cursor theme");

my $CURSOR_DIR = "/usr/X11R6/lib/X11/icons/";
my @THEMES;
my @DESCS;
open(LSPROC, "ls $CURSOR_DIR|") or die "cannot open $CURSOR_DIR\n";
while (<LSPROC>)
{
  my @themes = split(' ', $_);
  foreach $theme (@themes)
  {
    push @THEMES, $theme;
    push @DESCS, $theme;
  }
}
close(FILE);

# print "Themes:\n";
# foreach $x (@THEMES)
# {
#   print ">$x<\n";
# }

# print "descs:\n";
# foreach $x (@DESCS)
# {
#   print ">$x<\n";
# }

