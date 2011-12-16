#!/usr/bin/env perl
require ("/home/davep/bin/dpbug.pl");

$list_all = 0;
($todo_file = $ENV{'TODO'}) ||
    ($todo_file = "$ENV{'HOME'}/etc/pdb/todo.pdb");

$query = "";
$func = "";

#
# This is a pdb subroutine.  It is called from pdb, which is 
# run from this program.  It cannot share any variables from this
# program.
#
$list_rec_fn = <<'EOC'
{
    local($fi);
    local($x) = "todo-dates";

#     for $key (keys(%fields))
#     {
# 	print "fields{$key}:$fields{$key}:\n";
#     }
#     print "d: ", $fields{$x}, "\n";
#     print "ds: ", $fields{'todo-dates'}, "\n";
#     print "dd: ", $fields{"todo-dates"}, "\n";
#
#    print "$fields{todo-dates}\n";
#    print "t/f:", $fields{"todo-dates"} =~ /done/, ": list_all: $list_all\n";

    local($eof_ind) = @_;
    return if $eof_ind;

    return if (!$list_all &&
	       $fields{"todo-dates"} =~ /done\:/);

    for ($fi = 0; $fi < $fieldIndex; $fi += 2)
    {
	&print_rec($thisRec[$fi], $thisRec[$fi + 1]); # this is in pdb
    }
    print $rec_sep_print;
}
EOC
    ;

sub list
{
    $query = $ARGV[0];
    system("pdb -f todo -r '" . $list_rec_fn . "' $query < $todo_file");
}

sub edit
{
    $editor = $ENV{'EDITOR'};
    $editor = "vi" if !$editor;

    system("$editor $todo_file");

}

sub append
{
    open (TAIL, "tail -3 $todo_file|") || die("cannot tail $todo_file");
    @lines = <TAIL>;
    close(TAIL);

    if ($lines[2] =~ /^\n$/)
    {
#	print "ends w/empty line\n";
	$prefix="";
    }
    elsif ($lines[2] =~ /\n$/)
    {
#	print "last line has nl\n";
	$prefix="\n";
    }
    else 
    {
#	print "no nl on last line\n";
	$prefix="\n\n";

    }
#    print "will add:\n${prefix}record data\n";

    open(TODO, ">>$todo_file") || die "Cannot open $todo_file: $!\n";
    print TODO $prefix, "todo-dates ", scalar localtime(), "\n";
    print TODO "todo ", join(' ', @ARGV), "\n\n";
    close(TODO);
}

while ($ARGV[0] =~ /^[\/\-]/)
{
    $_ = shift;
   
    if (/^[\/\-]l/)
    {
	$func = 'list';
    }
    elsif (/^[\/\-]e/)
    {
	$func = 'edit';
    }
    elsif (/^[\/\-]a/)
    {
	$func = 'add';
    }
    elsif (/^[\/\-]A/)
    {
	$list_all = 1;
    }
}

# print "func>$func<\n";
# print "#ARGV>$#ARGV<\n";

if ($func eq "")
{
    if ($#ARGV < 0)
    {
	$func = 'list';
    }
    else
    {
	$func = 'add';
    }
}

# print "func>$func<\n";

if ($func eq 'add')
{
    &append;
}
elsif ($func eq 'list')
{
    &list;
}
elsif ($func eq 'edit')
{
    &edit;
}
else
{
    die "unknown func>$func<\n";
}

exit(0);

