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

: ${log_name_base:=t_make}
: ${log_name:=}
: ${clean_opt=}
: ${rtl_opt=-skiprtl}
: ${disp_file=/proc/self/fd/1}
: ${make_p=t}
: ${log_dir=t_make+log.logs}    # Since we cd to tot.
: ${keeplogs_opt=-keepLogs}
: ${leavelogs_opt=-leaveLogs}
: ${catlog_opt=-catlog}
: ${only_opt=}
: ${get_mods_p=a}
: ${build_me_p=a}
: ${debug_opt=-debug=1}
: ${me_purge_opt=purge}
: ${me_clean_opt=}
: ${send_mail_on_completion=t}

t_make_args=

Usage_args_info=" t_make args..."
Usage_synopsis="Do a t_make at TOT:
"
Usage_details="${EExec_parse_usage}
-o <file>) Tee output to log to <file>.<time stamp>
-O <file>) Tee output to log to <file>.
--no-log) tee /dev/null to show progress but make no log.
--no-keeplogs) Tell t_make not to keep log files about.
--no-leavelogs) Tell t_make not to leave previous log files about.
--no-catlog) Do not cat the log after a failure.
--quiet) tee <log-file> > /dev/null. Log w/o output.
-r) Do NOT use -skiprtl. Build the RTL
--rtl) ibid
--only <target>) Only make <target>
--t_make_arg <arg>) Append <arg> to additional t_make args.
--get-mods) Get the latest mods. 
--no-get-mods) Get the latest mods.
--build-me) Do build the me tests.
--no-build-me) Do not build the me tests.
--no-debug) Build me tests W/O debug.
--me-purge) Purge me tests.
--no-me-purge) Don't purge me tests.
-c) Do a -clean first
--clean) Clean me tests.
--no-clean) Don't clean me tests.
--mm|--mme|--gb|--get-build|--all) Get mods AND make me tests.
-nn) Don't get mods or make me tests.
-m|--no-make|--no-build) Don't do the basic bin/t_make(s)
--mail) Send mail when complete.
--no-mail) Don't
"

long_options=("out-file:" 
    "this-out-file:"
    "clean"
    "no-skiprtl"
    "skiprtl"
    "rtl"
    "null" 
    "quiet"
    "no-make" 
    "no-build"
    "no-log"
    "no-keeplogs"
    "no-leavelogs"
    "no-catlogs"
    "get-mods"
    "no-get-mods"
    "build-me"
    "no-build-me"
    "no-debug"
    "debug"
    "me-purge"
    "no-me-purge"
    "me-clean"
    "no-me-clean"
    "mm" "mme" "gb" "get-build" "all"
    "nn"
    "mail" "no-mail"
    "only:")

# Example of arg parsing.
option_str="${EExec_parse_option_str}o:O:crm"
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
      -r|--no-skiprtl|--rtl) rtl_opt="";;
      --no-log) log_name="/dev/null";;
      --quiet) disp_file=/dev/null;;
      -m|--no-make|--no-build) make_p=;;
      --no-keeplogs) keeplogs_opt=;;
      --no-leavelogs) leavelogs_opt=;;
      --no-catlog) catlog_opt=;;
      # t_make won't accept -only and -skip*
      --only) shift; only_opt="-only $1"
              [ -n "${rtl_opt}" ] && {
                  echo 1>&2 "-only ${1} disabling -skiprtl"
                  rtl_opt=
              }
              ;;
      # t_make won't accept -only and -skip*
      --skiprtl) rtl_opt="-skiprtl"
                 [ -n "${only_opt}" ] && {
                     echo 1>&2 "-skiprtl disabling  ${only_opt}"
                     only_opt=
                 }
                 ;;
      --t_make_arg) shift; t_make_args="$t_make_args $1";;
      --build-me) build_me_p=t;;
      --no-build-me) build_me_p=;;
      --get-mods) get_mods_p=t;;
      --no-get-mods) get_mods_p=;;
      --no-debug) debug_opt=;;
      --debug) debug_opt="-debug=1";;
      --no-me-purge) me_purge_opt=;;
      --me-purge) me_purge_opt="purge";;
      --no-me-clean) me_clean_opt=;;
      --me-clean) me_clean_opt="clean";;
      --mm|--mme|--gb|--get-build|--all) get_mods_p=t; build_me_p=t;;
      --nn) get_mods_p=; build_me_p=;;
      --mail) send_mail_on_completion=t;;
      --no-mail) send_mail_on_completion=;;

      # Help!
      --help) Usage; exit 0;;
      --) shift ; break ;;
      *) echo 1>&2 "Unsupported option>$1<"
         exit 1;;
    esac
    shift
done

# It's ok... it builds using lsf.
#on-o-xterm-p && ! EExecDashN_p && {
#    echo "$progname: Should not do this on an o-xterm box."
#    exit 1
#} 1>&2


rtl_required_p && [ "${rtl_opt}" == "-skiprtl" ] && {
    echo "This sandbox cannot skip rtl"
    exit 1
}

[ -z "${log_dir}" ] && {
    echo "log_dir is not set. Using cwd"
    log_dir="${PWD}"
} 1>&2

[ -z "$log_name" ] && {
    log_name="${log_dir}/${log_name_base}.$(dp-std-timestamp)"
}

log_name=$(realpath "$log_name")

mail_results()
{
    EExecDashN_p && send_mail_on_completion=
    if vsetp "${send_mail_on_completion-}"
    then
        echo "$PWD" | mail -s "$progname is done" "${USER}" 2>&1
    else
        cat > /dev/null
    fi
}

trap_fun()
{
    {
        local sig="${1-}"; shift
        local log_name="${1}"; shift

        EExecDashN_p && {
            echo "${progname}: Running w/-n, removing log file>${log_name}<"
            rm -rf "${log_name}"
            log_name=
        }
        if ((sig != 0))
        then
            echo "${progname}: sig>$sig<"
            trap "" 0
            exit 1
        else
            echo "${progname}: Success"
        fi
        EExecVerbose_p && vsetp "${log_name}" && {
            echo "==== Log file start: ${log_name} ==="
            cat "${log_name}"
            echo "==== Log file end: ${log_name} ==="
        }
    } 2>&1 | tee /dev/tty | tee -a "${log_name}" | mail_results
}

for sig in 0 2 3 4 5 6 7 8 15
do
	trap "trap_fun ${sig} ${log_name}" $sig
done

run_t_make()
{
    echo "${PWD}/bin/t_make ${keeplogs_opt} ${leavelogs_opt} ${t_make_args} ${catlog_opt} ${only_opt} $@" \
         | EExec -y tcsh-run ${EExecDashN_opt}
}

# Make this because we tee to a file inside this dir. The tee is part of the
# following redirection and gets created before any of the commands inside
# the {} run
EExec mkdir -p "${log_dir}"

{
    EExecDashN_p && send_mail_on_completion=
    if [ -n "$make_p" ]
    then
        EExec -y cd $(me-dogo tot)
        [ -e "tree.make" ] || {
            echo "tree.make does not exist."
            exit 1
        } 1>&2

        EExec_verbose_msg "cwd>$(pwd)<"
        EExec_verbose_msg "log_name>${log_name}<"
        EExec_verbose_msg "disp_file>${disp_file}<"
        [ -n "${clean_opt}" ] && {
            run_t_make ${clean_opt}
            #echo "bin/t_make ${keeplogs_opt} ${clean_opt}" | EExec -y tcsh-run ${EExecDashN_opt}
        }

        #echo "bin/t_make ${keeplogs_opt} ${rtl_opt}" | EExec -y tcsh-run ${EExecDashN_opt}
        run_t_make ${rtl_opt} || {
            echo "!!!!!!!!!!! t_make failed !!!!!!!!!!!"
            banner "t_make failed."
            exit 1
        } 1>&2

    fi

    # Other things useful after a make:
    # 1) get mods
    # 2) ./build_gpu_multiengine.pl

    # 1
    while [ "${get_mods_p}" = "a" ]
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
    done

    if [ -n "${get_mods_p}" ]
    then
        EExec --keep-going ./bin/get_mods
    fi

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
    done

    if [ -n "${build_me_p}" ]
    then
        [ -n "${me_purge_opt}" ] && {
            EExec ./build_gpu_multiengine.pl ${me_purge_opt}
        }
        [ -n "${me_clean_opt}" ] && {
            EExec ./build_gpu_multiengine.pl ${me_clean_opt}
        }
        EExec ./build_gpu_multiengine.pl ${debug_opt}
    fi

    echo "Log file: ${log_name}"
} | tee "${log_name}" > "${disp_file}"

exit 0
