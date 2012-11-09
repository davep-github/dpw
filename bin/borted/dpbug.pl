if (!defined &pvars_sep) {
    eval <<'END_SUB'
sub pvars_sep {
    local($sep, $term, $o_char, $c_char, @vars) = @_;

    $tsep = '';
    foreach $var (@vars)
    {
	print STDERR "$tsep$var$o_char";
	eval "print STDERR \$$var";
	print STDERR "$c_char";
	$tsep = $sep;
    }
    print STDERR "$term";
}
END_SUB
}

if (!defined &pvars) {
    eval <<'END_SUB'
sub pvars {
    &pvars_sep(', ', "\n", ">", "<", @_);
}
END_SUB
}

1;
