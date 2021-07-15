#!/bin/sh
# Give another hint for auto-mode-ing.

# $HOME/bin/dp-getopt+.eg.sh
# Set variable_defaults.
# The = means the variable gets the default if it unset, but not null.
# The := unset OR null.  Use this if "" is a bad value.
# Use true and false for binary ops.  These are builtins so there's no extra
# overhead.
# this
# if $binary_var; then echo woo hoo; else echo I has the sadz; fi
# if [[ "$binary_var" ~= t|true|1 ]]
# : ${flag_o:=false}
# : ${option_with_arg=default}

# Using this style of variable args allows the variables to be used on the
# command line.
# e.g. $ flag_o=true option_with_arg="" program

# Usage variable usage:
Usage_args_info=' You should really set "$Usage_args_info", you lazy bastard'
Usage_synopsis='You should really set "$Usage_synopsis", you lazy bastard
# Idiom:
# Using ) after the args makes copy & paste between here and the
# case statement easier.
# Who the FUCK is ever going to read this?  Besides me?
# Anyone else, please send an email to davep.i-read-a-comment@meduseld.net
# [ as of: 2021-06-17T01:28:39 ] this is a working domain name email address.
# But domains expire, dunnaye?
# Usage_details="${EExec_parse_usage}
# -o|--flag-o) flag o
# -O <val>|--option-with-arg) set Option to val [${option_with_arg}]
# "
# Example of arg parsing.
# option_str="fFo:"
# declare -a long_options
# Each element is a long option name sans '--'
# long_options=(
#     "flag-o"			# -f
#     "no-flag-o"		# -F
#     "option-with-arg:"	# -o
#     ...)
'
source dp-getopt+.sh || exit 1

while (($# > 0))
do
  # do. e.g.  shift; $OPTION_ARG=$1;; # to process options with arguments.
  case $1 in
      # eexec support: -n -v -q, etc.
      # Is done inside EExec_parse and friends.
      # q.v. ~/bin/eexec

      # Program parameters
      # -f|--flag-o) flag_o=true;;
      # -f|--no-flag-o) flag_o=false;;
      ## shift consumes option name.
      # -o|--option-with-arg) shift; arg="${1}";
      # "Let's do get help."  This option is added inside dp-getopt+.sh
      --help) Usage; exit 0;;
      --) shift ; break ;;
      # getopt will barf about unknown options.
      # Here we barf about known options that we have forgotten to handle.
      *) echo 1>&2 "Unhandled option>$1<"
         exit 1;;
    esac
    shift
done
# The following is needed only when args are required.
# [ "$*" = "" ] && {
#     Usage2 "FATAL: Args required, but noooo.  None provided."
#     exit 1
# }
