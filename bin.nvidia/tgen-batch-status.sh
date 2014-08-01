#!/bin/sh

source script-x
set -u
progname="$(basename $0)"
source eexec
if vsetp "${eexec_program-}"    # Did the caller provide a program?
then
    EEXEC_SHIFT=:
else
    eexec_program=$(EExec_parse "$@")
    EEXEC_SHIFT=shift
fi

for op in $eexec_program
do
  $op
  ${EEXEC_SHIFT}
done
EExec_verbose_msg $(echo_id eexec_program)
unset eexec_program
#export eexec_program
# Or export eexec_program to propagate eexec info to a called program.
# export eexec_program

trap_msg=
in_file=
no_header=

clean_up()
{
    local msg=${1-}
    [ -z "${in_file}" ] \
      && vsetp "${tmp_file}" \
      && [ -e "${tmp_file}" ] \
      && vunsetp "${keep_tmp_p}" \
      && {
        EExec_verbose_msg "${progname}: ${msg}Removing tmp_file>${tmp_file}<"
        rm -f "${tmp_file}"
    }
}

# Useful traps
on_exit()
{
    local rc="$?"
    local signum="${1-}"; shift

    clean_up "on_exit: "

    EExec_verbose_msg "on_exit: rc: $rc; ${trap_msg}"
}

on_error()
{
    local sig="${1}"
    local rc="${1-}"; shift

    clean_up "on_error: "

    EExec_verbose_msg "on_error: sig: $sig, rc: $rc; ${trap_msg}"
    trap '' 0
}

trap on_exit EXIT
for sig in 2 3 4 5 6 7 8 15
do
	trap "on_error $sig" $sig
done

: ${run_num=0}

: ${status_regexp=.*}
tmp_file=$(mktemp "$HOME/tmp/tgen-batch-status.tmp.XXXXXXX") || {
    echo "Couldn't make a temp file."
    exit 1
} 1>&2

EExec_verbose_echo_id tmp_file

option_str="t:r:fdps0123456789i:c"
long_options=(
    "test:" "test-name:"
    "test-dir:" "test-root:"
    "files" "show-test-file-names"
    "dirs" "dirname" "dname" "dn"
    "just-path"
    "just-logs"
    "just-scripts" "just-sh"
    "full-path" "path" "real-path" "rp"
    "status-regexp:" "sre:"
    "srv:" "status-not-regexp:" "not-status-regexp:" "status-regexp-v:"
    "not-running" "done" "exited" "finished"
    "running"
    "not-done"
    "failed" "b0rked" "error" "errors" "fail"
    "not-failed" "not-b0rked" "not-error" "not-fail"
    "passed" "success" "good" "pass"
    "gold"
    "killed"
    "in-file:" "in:" "if:"
    "nth:" "run-num"
    "log"
    "script" "sh"
    "no-post-process" "npp"
    "post-process-arg:" "ppa:"
    "add-suffix:" "add-extension:" "add-ext:"
    "raw"
    "just-test-name" "just-test" "jtn" "short" "terse" "simple" "basic"
    "no-header" "noh" "no-hdr" "nh"
    "header" "hdr"
    "invert" "invert-flag" "not" "not-flag"
    "vert" "vert-flag"
    "count" "wcl" "wc" "wc-l"
    "keep-raw-output" "keep-tmp-file"
    "no-trep"
    "keep-trep"
    "run-dir" "rd"
)

test_name_opt=
test_dir=
output_transform=full_path
invert_flag=
post_process=add_dot_log
just_path=cat
post_process_arg=
counter=cat
keep_tmp_p=
trep_filter=strip_trep
just_run_dir_p=
count_p=
# <:vars:>
source dp-getopt+.sh || exit 1
while (($# > 0))
do
  # do. e.g.  shift; $OPTION_ARG=$1;; # to process options with arguments.
  case $1 in
      # eexec support
      # Done by EExec_parse and friends.

      # Program options.
      -[0-9]) run_num="${1}";;  # More than -9 will require --nth, et. al.
      -t|--test|--test-name) shift; test_name_opt="--test-name ${1}";;
      -r|--test-dir|--test-root) shift; test_dir="${1}";;
      -f|--files|--show-test-file-names) output_transform=cat;;
      -d|--dirs|--dirname|--dname|--dn) post_process=dirname_only;;
      --just-path) just_path=just_path; no_header=t;;
      -s|--just-test-name|--just-test|--jtn|--short|--terse|--simple|--basic) just_path=just_test_name; post_process=cat; no_header=t;;
      --just-logs) just_path=just_path; post_process=add_dot_log; no_header=t;;
      --just-scripts|--just-sh) just_path=just_path; post_process=add_dot_sh;;
      -p|--full-path|--path) output_transform=full_path;;
      --real-path|--rp) 
          output_transform=real_path;;
      --status-regexp|--sre) shift; status_regexp="${1-}";;
      --srv|--status-not-regexp|--not-status-regexp|--status-regexp-v) shift; status_regexp="${1}"; invert_flag='-v';;
      --not-running|--done|--exited|--finished) status_regexp="^(RUNNING|NOTRUN)"; invert_flag='-v';;
      --failed|--b0rked|--error|--errors|--fail) status_regexp="^(NOTRUN|RUNNING|PASS_(GOLD|LEAD))"; invert_flag='-v';;
      --no-failed|--not-b0rked|--not-error|--not-fail) status_regexp="^(NOTRUN|RUNNING|PASS_(GOLD|LEAD))";;
      --passed|--success|--good|--pass) status_regexp="^(PASS_(GOLD|LEAD))";;
      --gold) status_regexp="^(PASS_GOLD)";;
      --killed) status_regexp="^(ERROR_KILL)";;
      --running) status_regexp="^RUNNING";;
      --not-done) status_regexp="^(RUNNING|NOTRUN)";;
      -i|--in-file|--in|--if) shift; in_file=$(realpath "${1}");;
      --nth|--run-num) shift; run_num="${1}";;
      --log) post_process=add_dot_log;;
      --script|--sh) post_process=add_dot_sh;;
      --no-post-process|--npp) post_process=cat;;
      --post-process-arg|--ppa) shift; post_process_arg="${1}";;
      --add-suffix|--add-extension|--add-ext)
          shift; post_process_arg="${1}"
          post_process=add_suffix
          ;;
      --raw) output_transform=cat
             post_process=cat
             post_process_arg=
             just_path=cat
             no_header=t
             ;;
      --keep-tmp|--keep-tmp-file|--keep-raw|--keep-raw-file) keep_tmp_p=t;;
      --no-header|--noh|--no-hdr|--nh) no_header=t;;
      --header|--hdr) no_header=;;
      --invert|--invert-flag|--not|--not-flag) invert_flag=t;;
      --vert|--vert-flag) invert_flag=t;;
      -c|--count|--wcl|--wc|--wc-l) count_p=t; counter=wc_counter;;
      --no-trep) trep_filter=strip_trep;;
      --keep-trep) trep_filter=cat;;
      --run-dir|--rd) just_run_dir_p=t;;
      # Help!
      --help) Usage; exit 0;;
      --) shift ; break ;;
      *) echo 1>&2 "Unsupported option>$1<"
         exit 1;;
    esac
    shift
done

EExec_verbose_echo_id output_transform

dirname_only()
{
    # like dirname, but it works with stdin.
    sed -rn 's!(.*)(/[^/]*$)!\1!p'
}

basename_only()
{
    # like basename, but it works with stdin.
    sed -rn 's!(.*?)/([^/]+)$!\2!p'
}

# No script or log name.
just_path()
{
    sed -rn 's/(.*[[:space:]])([^[:space:]]+$)/\2/p'
}

just_test_name()
{
    sed -rn 's!([[:space:]]*)([^[:space:]]+)([[:space:]]+)((.*?)/([^/]+)$)!\2 \t \6!p'
}    

add_suffix()
{
    local suffix="${1}"
    shift
    sed -rn "s/(.*)/\1${suffix}/p"
}

add_dot_log()
{
#    sed -rn 's/(.*)/\1.log/p'
    add_suffix ".log"
}

add_dot_sh()
{
#    sed -rn 's/(.*)/\1.log/p'
    add_suffix ".sh"
}

: ${test_dir:=$(tgen-latest-run --run-num "${run_num}" --test-dir ${test_name_opt})}
rel_test_dir=$(realpath -r "${test_dir}")

full_path()
{
    sed -rn "s|tests/|${test_dir}/tests/|p"
}

real_path()
{
    sed -rn "s!tests/!$(realpath ${rel_test_dir})/tests/!p"
}

wc_counter()
{
    wc -l
}

strip_trep()
{
    awk '{print $1 " " $3}'
}

num_lines=0
OPWD="${PWD}"

true_p "${just_run_dir_p}" && {
    echo "${test_dir}"
    exit 0
}

vunsetp "${no_header}" \
&& vunsetp "${count_p}" \
&& {
    echo "Getting status for ${test_dir}"
}

if vsetp "${in_file}"
then
    if [ "${in_file}" = '-' ]
    then
        tmp_file=/proc/self/fd/0
    else
        tmp_file="${in_file}"
    fi
else
    (
        EExec -y cd $(me-expand-dest "testgen")
        EExec ./batch_status "${test_dir}" >| "${tmp_file}"
    )
fi

# Lines look like this:
# ERROR_SIM     a5ea8e9ada2a405c4d9060aad5112aa0     a-test-path/00/01/50/000150/atom35_64_maxs64
# Usually with lots of white space at the end of the line.

EExec cat "${tmp_file}" \
            | strip-white-space.py \
            | EExec "${trep_filter}" \
            | EExec "${output_transform}" \
            | EExec -0 egrep ${invert_flag} "${status_regexp}" \
            | EExec "${post_process}" ${post_process_arg} \
            | EExec "${just_path}" \
            | EExec "${counter}"

EExec_verbose_msg "Total number of lines: $(wc -l ${tmp_file})"
rc=$?

true_p "${keep_tmp_p}" && {
    echo_id -t "Keeping tmp file: " tmp_file
}

# Let the exit handler do this.
#rm -f "${tmp_file}"
#tmp_file=

exit $rc
