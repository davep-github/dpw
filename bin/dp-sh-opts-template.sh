#!/bin/sh

source script-x
source eexec
# These are convenient for eexec
: ${eexec_options='nvq'}

doc_string='What this program does.'

# Simple way to get the equivalent of keyword arguments:
# This sets a default which can be overridden thus:
# cheap_keyword_arg=not-blah some-program <other args>
#: ${cheap_keyword_arg:=blah}

option_str="this is the place for options"  # <:add new options:>
all_options="${option_str}${eexec_options-}"
q=$(getopt -o "$all_options" -- "$@")
[ $? != 0 ] && Usage
eval set -- "$q" 
unset q

for i in "$@"
do
  # do. e.g.  $OPTION_ARG=$2; shift;; to process options with arguments.
  case $1 in
      -n) EExecDashN;;          # Don't actually execute stuff
      -v) EExecVerbose;;        # Blah, blah, blah.
      -q) EExecQuiet;;

      # Your other options go here.
      # An example of options which have values:
      -Z) shift; zee_var="$1";;

      --) shift ; break ;;
      *) 
      echo 1>&2 "Unsupported option>$1<";
      Usage
      exit 1 ;;
    esac
    shift
done

