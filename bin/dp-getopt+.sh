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

# defaults to placate -u and to educate user of this -- $0 -- utility.
: ${DPGOP_Usage_args_info=${Usage_args_info="INFO: \$Usage_args_info is null.
"}}
: ${DPGOP_Usage_synopsis=${Usage_synopsis="INFO: \$Usage_synopsis is null.
"}}
: ${DPGOP_Usage_details=${Usage_details="INFO: \$Usage_details is null.
"}}

DPGOP_Usage()
{
    [[ -n "$@" ]] && echo "${progname}: $@"
    set +u                      # XXX @todo ICK!
    if ((${#long_options[@]} > 0))
    then
        loo=$(addprefix_prefix_sep="" addprefix "--" "${long_options[@]}")
        loo="[${loo}]"
    else
        loo=""
    fi
    set -u                      # XXX @todo unICK!

    echo -n "Usage: ${progname} [-$all_options]${loo}$DPGOP_Usage_args_info
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
  ###source eexec Why? This invocation will stomp things set by an earlier one.
  ### what will break now?
  [[ -z "${option_str}" ]] && [[ "${option_str-null}" == "null" ]] && \
   dpe_error 1 'EINVAL: option_str is null.  Set it to "" if you do not want options.'
  # Only replace values if the variable is null.
  : ${option_str=""}
  : ${all_options="$option_str"}
  : ${getopt_args=""}
  : ${long_options=""}          # Just names. We'll add the --longoption
  : ${long_help_option="--longoption help"}
  long_options_opt=
  [ -n "$long_options" ] && {
      long_options_opt=$(addprefix "--longoption" "${long_options[@]}")
  }

  # New style getopt... fixes ugly quoting problems. Wh00t!
  q=$(getopt $getopt_args -o "$all_options" \
        $long_options_opt $long_help_option -- "$@")
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

#
# A snippet/template for ease of use.
#

#e.g.# # Usage variable usage:
#e.g.# Usage_args_info=" errno..."
#e.g.# Usage_synopsis="Display various info about errno...:
#e.g.# "
#e.g.# # Using ) after the args makes copy & paste between here and the 
#e.g.# # case statement easier.
#e.g.# Usage_details="${EExec_parse_usage}
#e.g.# -o) flag o
#e.g.# -O <val>) set Option to <val>
#e.g.# "
#e.g.# # Example of arg parsing.
#e.g.# option_str="${EExec_parse_option_str}"
#e.g.# # long_options=("option-name-without-leading--" ...)
#e.g.# source dp-getopt+.sh
#e.g.# for i in "$@"
#e.g.# do
#e.g.#   # do. e.g.  shift; $OPTION_ARG=$1;; # to process options with arguments.
#e.g.#   case $1 in
#e.g.#       # eexec support
#e.g.#       -n) EXEC=echo; EExecDashN;; # Don't actually execute stuff
#e.g.#       -v) VERBOSE="echo $progname: "; EExecVerbose;;
#e.g.#       -q) VERBOSE=":"; EExecQuiet;;
#e.g.# 
#e.g.#       # Program options.
#e.g.#
#e.g.#       # Help!
#e.g.#       --help) Usage; exit 0;;
#e.g.#       --) shift ; break ;;
#e.g.#       *) echo 1>&2 "Unsupported option>$1<"
#e.g.#          exit 1;;
#e.g.#     esac
#e.g.#     shift
#e.g.# done
#e.g.# # The following is needed only when args are required.
#e.g.# [ "$*" = "" ] && Usage

