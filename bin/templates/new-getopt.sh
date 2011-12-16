# New style getopt... fixes ugly quoting problems.
q=$(getopt -o "$all_options" -- "$@")
[ $? != 0 ] && Usage
eval set -- "$q" 
unset q
