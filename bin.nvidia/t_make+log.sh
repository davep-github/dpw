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

# Usage variable usage:
Usage_args_info=" t_make args..."
Usage_synopsis="Do a t_make at TOT:
"
Usage_details="${EExec_parse_usage}
-o <file> -- Tee output to log to <file>.<timestamp>
-O <file> -- Tee output to log to <file>.
--no-log -- tee /dev/null to show progress but make no log.
--no-keeplogs -- Tell t_make not to keep log files about.
--quiet -- tee <log-file> > /dev/null. Log w/o output.
-c -- Do a -clean first
-r -- Do NOT use -skiprtl
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
    "no-keeplogs")

# Example of arg parsing.
option_str="${EExec_parse_option_str}o:O:cr"
source dp-getopt+.sh
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
    echo "bin/t_make ${keeplogs_opt} $@" | EExec -y tcsh-run ${EExecDashN_opt}
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
while :
do
  read -e -p "Get mods [y/N/q]? "
  case "$REPLY" in
      # Provide way to get args. E.g. set -- $REPLY. First word will be y/n/etc.
      # Shift it off and pass "$@" to get_mods
      [yY]) EExec --keep-going ./bin/get_mods;;
      [nN]|"");;
      [Qq]) exit 0;;
      *) continue;;
  esac
  break
done

#
EExec -y cd $(me-dogo testgen)

while :
do
  read -e -p "Build ME tests [Y/n/q]? "
  case "$REPLY" in
      [nN]) ;;
      [yY]|"") EExec ./build_gpu_multiengine.pl purge
            # Allow a way to do this w/o debug.
            EExec ./build_gpu_multiengine.pl -debug=1
            ;;
      [Qq]) exit 0;;
      *) continue;;
  esac
  break
done

