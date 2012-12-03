#!/bin/sh
#
# Overly baroque getopt extensions.
# Keep this file non-executable since it must be `source'd to work.
#
source script-x
set -u
: ${DPGOP_dont_warn_about_redefining_Usage=t}
: ${DPGOP_dont_redefine_Usage=t}
: ${DPGOP_dont_define_Usage=}

# Save "$@" in a way that preserves the existing tokenization.
dp_getopt_dat=("$@")            # Save "$@"
# set -- "${dat[@]}"               # Use saved "$@". Quotes are REQUIRED.

: ${progname:=$(basename $0)}
: ${dont_exec_p:=""}

#############################################################################
# Usage support.
# If define the vars if your usage pattern fits.
#

# Issue a warning 
# !<@todo XXX or don't redefine
# if Usage is already defined.
#

if vunsetp "$DPGOP_dont_define_Usage"
then
    usage_is_defined=$(type -t "Usage") && {
        vunsetp $DPGOP_dont_warn_about_redefining_Usage && {
            echo 1>&2 "$progname: Warning: Usage is already defined as $usage_is_defined."
        }
        DPGOP_dont_define_Usage=$DPGOP_dont_redefine_Usage
    }
fi

if vunsetp "$DPGOP_dont_define_Usage" 
then
    Usage()
    {
        DPGOP_Usage "$@"
    }
    Usage2()
    {
        Usage "$@" 1>&2
    }
fi

# Variable usage:
#e.g.# Usage_args_info=" errno..."
#e.g.# Usage_synopsis="Display various info about errno...:
#e.g.# "
#e.g.# Usage_details="-n name only.
#e.g.# -N emit name only without newline.
#e.g.# -s sort [same as -n].
#e.g.# -d description only.
#e.g.# -v be verbose (kinda for testing).
#e.g.# -t be terse (different that just non-verbose).
#e.g.# -p echo back args verbatim as entered (debugging).
#e.g.# -h print errno in hex.
#e.g.# -m print (0 - errno) (negative errno).
#e.g.# "

# defaults to placate -u and to educate user of this -- $0 -- utility.
: ${DPGOP_Usage_args_info=${Usage_args_info="INFO: \$Usage_args_info is null.
"}}
: ${DPGOP_Usage_synopsis=${Usage_synopsis="INFO: \$Usage_synopsis is null.
"}}
: ${DPGOP_Usage_details=${Usage_details="INFO: \$Usage_details is null.
"}}

DPGOP_Usage()
{
    [[ -n "$@" ]] && echo "$@"
    echo -n "${progname}: usage: [-$all_options]$DPGOP_Usage_args_info
$DPGOP_Usage_synopsis
$DPGOP_Usage_details"
}

DPGOP_Usage2()
{
    DPGOP_Usage "$@" 1>&2
}
#
# Usage support.
#############################################################################

# init optional vars to defaults here...
VERBOSE=:
DEBUG=:

running_as_script && {
  source eexec
  [[ -z "${option_str}" ]] && [[ "${option_str-null}" == "null" ]] && \
   dpe_error 1 'EINVAL: option_str is null.  Set it to "" if you do not want options.'
  # Only replace values if the variable is null.
  : ${option_str=""}
  : ${all_options="$option_str"}
  : ${getopt_args=""}
  : ${long_options=""}
  long_options_opt=
  [ -n "$long_options" ] && {
      long_options_opt=$(addprefix "--longoption" "${long_options[@]}")
  }

  # New style getopt... fixes ugly quoting problems. Wh00t!
  q=$(getopt $getopt_args -o "$all_options" $long_options_opt -- "$@")
  if [ $? = 0 ]
  then
      eval set -- "$q"
      dolAT=("$@")
      true
  else
      Usage2 "getopt failed."   # If getopt even returns after an error.
      false
  fi
}

# Example of arg parsing.
#eg# Usage_args_info="No args"
#eg# Usage_synopsis="Do something that would normally require typing 3 words."
#eg# Usage_details="Detailed args, raison de etre, etc."
#eg# option_str=""
#eg# source dp-getopt+.sh
#eg# for i in "$@"
#eg# do
#eg#   # do. e.g.  $OPTION_ARG=$2; shift;; to process options with arguments.
#eg#   case $1 in
#eg#       -n) EXEC=echo; EExecDashN;; # Don't actually execute stuff
#eg#       -v) VERBOSE="echo $progname: "; EExecVerbose;;
#eg#       -q) VERBOSE=":"; EExecQuiet;;
#eg#       # -d is really just verbosity
#eg#       -d) EExecVerbose; DEBUG="echo 1>&2 $progname: ";;
#eg#       # superseded by . script-x# -D) set -x;;
#eg#       --) shift ; break ;;
#eg#       *) 
#eg#       echo 1>&2 "Unsupported option>$1<";
#eg#       Usage
#eg#       exit 1 ;;
#eg#     esac
#eg#     shift
#eg# done
# The following is needed only when non optional args are required.
#[ "$@" = "" ] && Usage

