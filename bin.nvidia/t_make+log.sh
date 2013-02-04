#!/bin/sh

source script-x
set -u
progname="$(basename $0)"
source eexec
eexec_program=$(EExec_parse "$@")
for op in $eexec_program
do
  $op
  shift
done
unset eexec_program

on-o-xterm-p && {
    echo "$progname: Should not do this on an o-xterm box."
    exit 1
} 1>&2

: ${log_name_base:=t_make}
: ${log_name:=}
: ${clean_opt=}
: ${rtl_opt=-skiprtl}
: ${disp_file=/proc/self/fd/1}
: ${make_p=t}
: ${log_dir=t_make+log.logs}    # Since we cd to tot.
: ${keeplogs_opt=-keepLogs}
: ${only_opt=}
: ${get_mods_p=a}
: ${build_me_p=a}
: ${debug_opt=-debug=1}
: ${purge_opt=purge}

t_make_args=

# Usage variable usage:
Usage_args_info=" t_make args..."
Usage_synopsis="Do a t_make at TOT:
"
Usage_details="${EExec_parse_usage}
-o <file> -- Tee output to log to <file>.<time stamp>
-O <file> -- Tee output to log to <file>.
--no-log -- tee /dev/null to show progress but make no log.
--no-keeplogs -- Tell t_make not to keep log files about.
--quiet -- tee <log-file> > /dev/null. Log w/o output.
-c -- Do a -clean first
-r -- Do NOT use -skiprtl
--only <target> -- Only make <target>
--t_make_arg <arg> -- Append <arg> to additional t_make args.
--get-mods -- Get the latest mods. 
--no-get-mods -- Get the latest mods.
--build-me -- Do build the me tests.
--no-build-me -- Do not build the me tests.
--no-debug -- Build me tests W/O debug.
--purge -- Purge me tests.
--no-purge -- Don't purge me tests.
--mm -- Get mods AND make me tests.
"

long_options=("out-file:" 
    "this-out-file:"
    "clean"
    "no-skiprtl"
    "null" 
    "quiet"
    "no-make" 
    "no-build"
    "no-log"
    "no-keeplogs"
    "get-mods"
    "no-get-mods"
    "build-me"
    "no-build-me"
    "no-debug"
    "debug"
    "purge"
    "no-purge"
    "mm"
    "only:")

# Example of arg parsing.
option_str="${EExec_parse_option_str}o:O:cr"
source dp-getopt+.sh || {
    exit 1
}
for i in "$@"
do
  # do. e.g.  shift; $OPTION_ARG=$1;; # to process options with arguments.
  case $1 in
      # eexec support
      -n) EXEC=echo; EExecDashN;; # Don't actually execute stuff
      -v) VERBOSE="echo $progname: "; EExecVerbose;;
      -q) VERBOSE=":"; EExecQuiet;;

      # Program options.
      -o|--out-file) shift; log_name_base="$1";;
      -O|--this-out-file) shift; log_name="$1";;
      -c|--clean) clean_opt="-clean";;
      -r|--no-skiprtl) rtl_opt="";;
      --no-log) log_name="/dev/null";;
      --quiet) disp_file=/dev/null;;
      --no-make|--no-build) make_p=;;
      --no-keeplogs) keeplogs_opt=;;
      # t_make won't accept -only and -skip*
      --only) shift; only_opt="-only $1"; rtl_opt=;;
      --t_make_arg) shift; t_make_args="$t_make_args $1";;
      --build-me) build_me_p=t;;
      --no-build-me) build_me_p=;;
      --get-mods) get_mods_p=t;;
      --no-get-mods) get_mods_p=;;
      --no-debug) debug_opt=;;
      --debug) debug_opt="-debug=1";;
      --no-purge) purge_opt=;;
      --purge) purge_opt="purge";;
      --mm) get_mods_p=t; build_me_p=t;;
      # Help!
      --help) Usage; exit 0;;
      --) shift ; break ;;
      *) echo 1>&2 "Unsupported option>$1<"
         exit 1;;
    esac
    shift
done

[ -z "${log_dir}" ] && {
    echo "log_dir is not set. Using ."
    log_dir=.
} 1>&2

[ -z "$log_name" ] && {
    log_name="${log_dir}/${log_name_base}.$(dp-std-timestamp)"
}

run_t_make()
{
    echo "bin/t_make ${keeplogs_opt} $t_make_args $only_opt $@" \
         | EExec -y tcsh-run ${EExecDashN_opt}
}

if [ -n "$make_p" ]
then
    EExec -y cd $(me-dogo tot)
    EExec mkdir -p "${log_dir}"
    {
        EExec_verbose_msg "cwd>$(pwd)<"
        EExec_verbose_msg "log_name>${log_name}<"
        EExec_verbose_msg "disp_file>${disp_file}<"
        [ -n "${clean_opt}" ] && {
            run_t_make ${clean_opt}
            #echo "bin/t_make ${keeplogs_opt} ${clean_opt}" | EExec -y tcsh-run ${EExecDashN_opt}

        }

        #echo "bin/t_make ${keeplogs_opt} ${rtl_opt}" | EExec -y tcsh-run ${EExecDashN_opt}
        run_t_make ${rtl_opt}

    } | tee "${log_name}" > "${disp_file}"
fi

# Other things useful after a make:
# 1) get mods
# 2) ./build_gpu_multiengine.pl

# 1
while [ "{get_mods_p}" = "a" ]
do
  read -e -p "Get mods [y/N/q]? "
  case "$REPLY" in
      # Provide way to get args. E.g. set -- $REPLY. First word will be y/n/etc.
      # Shift it off and pass "$@" to get_mods
      [yY]) get_mods_p=t;;
      [nN]|"") get_mods_p=;;
      [Qq]) exit 0;;
      *) continue;;
  esac
  break
done

if [ -n "${get_mods_p}" ]
then
    EExec --keep-going ./bin/get_mods
fi

#
EExec -y cd $(me-dogo testgen)

while [ "${build_me_p}" = "a" ]
do
  read -e -p "Build ME tests [Y/n/q]? "
  case "$REPLY" in
      [nN]) build_me_p=;;
      [yY]|"") build_me_p=t;;
      [Qq]) exit 0;;
      *) continue;;
  esac
  break
done

if [ -n "${build_me_p}" ]
then
    [ -n "${purge_opt}" ] && {
        EExec ./build_gpu_multiengine.pl ${purge_opt}
    }
    EExec ./build_gpu_multiengine.pl ${debug_opt}
fi

exit 0
