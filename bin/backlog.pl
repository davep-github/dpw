#!/usr/bin/env perl

require('/home/davep/bin/dpbug.pl');

$trace = 1;

sub syscall
{
    $args = join(' ', @_);
    system($args) == 0 || die "system(@_) failed: $?\n";
}

sub next_in_numerical_series
{
    local($base) = @_;

    $last = `ls -1r ${base} 2> /dev/null | head -1`;
    ($v) = $last =~ /$log_base(\d+)/;
    ++$v;
}

sub is_binary_diff
{
    local($file) = @_;

    open (LFILE, $file) || die "cannot open $file: $1\n";
    $line = <LFILE>;
    close LFILE;

    $line =~ /^Binary files.*differ$/;
}

$log_base = 'diff-ver.';
$bin_base = 'bin-ver.';
$back_root = '/tmp';

$file = $ARGV[0];
$bdir = "$back_root/$file";
$new = "$bdir/new";
$latest = "$bdir/latest";
&pvars(file, bdir, new, latest);

# create dir w/same name as file under BACK_ROOT (== bdir)
if ( ! -d $bdir) {
    #
    # if it's a new dir, then just copy to latest and we're done
    #
    die "$bdir is a file\n" if (-f $bdir);
    print "new bdir, just copying\n" if $trace;
    @sys = ('mkdir', '-p', $bdir);
    system(@sys) if ! -d $bdir || die "system(@sys) failed: $?\n";
    &syscall('cp', '-p', $file, $latest);
}
else
{
    die "$new already exists; please correct" if (-f $new);
    # copy file to bdir/new
    &syscall('cp', '-p', $file, $new);

    # diff -c bdir/new bdir/latest > `next_diff_file`
    print "find new diff num\n" if $trace;
    $v = &next_in_numerical_series("$bdir/$log_base*");
    $diff_log = "$bdir/$log_base$v";
    die "next log ($diff_log) already exists; please correct" 
	if (-f $diff_log);

    print "diff'ing\n" if $trace;
    $rc = 0xffff & system("diff -c $new $latest > $diff_log");
    if ($rc == 0) {	# no diffs
	warn "no diffs in $latest $new\n";
	$cnt = unlink($new);
	die "cannot unlink $new: $!" if ($cnt != 1);
	$cnt = unlink($diff_log);
	die "cannot unlink $diff_log: $!" if ($cnt != 1);
    }
    elsif (($rc & 0xff00) != 0x0100) {
	die "diff failed: $?\n";
    }
    else
    {
	# diffs existed, check for special case of binary files.
	# "Binary files $f1 and $f2 differ"
	# if we're binariy, just keep multiple
	# versions.  Rename current latest to
	# next binary version
	if (&is_binary_diff($diff_log)) {
	    print "handling binary diff\n" if ($trace);
	    $v = &next_in_numerical_series("$bdir/$binary_base*");
	    $new_ver = "$bdir/$bin_base$v";
	    $cnt = rename($latest, $new_ver);
	    die "cannot rename $diff_log to $new_ver: $!" if ($cnt != 1);
	    $cnt = unlink($diff_log);
	    die "cannot unlink $diff_log: $!" if ($cnt != 1);
	}
	else {
	    # rm bdir/latest
	    $cnt = unlink($latest);
	    die "cannot unlink $latest: $!" if ($cnt != 1);
	}

	# mv bdir/new bdir/latest
	$cnt = rename($new, $latest);
	die "cannot rename $new to $latest: $!" if ($cnt != 1);
    }
}
