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

clean_up()
{
    local msg=${1-}
    [ -z "${in_file}" ] && [ -n "${tmp_file}" ] && [ -e "${tmp_file}" ] && {
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

option_str="t:r:fdps:0123456789"
long_options=(
    "test:" "test-name:"
    "test-dir:" "test-root:"
    "files"
    "dirs"
    "full-path" "path" "real-path" "rp"
    "status-regexp:" "sre:"
    "srv:" "status-not-regexp:" "not-status-regexp:" "status-regexp-v:"
    "not-running" "done" "exited" "finished"
    "running"
    "not-done"
    "failed" "b0rked" "error" "fail"
    "not-failed" "not-b0rked" "not-error" "not-fail"
    "passed" "success" "good" "pass"
    "in-file:" "in:" "if:"
    "nth:" "run-num"
)

test_name_opt=
test_dir=
output_filter=full_path
invert_flag=

source dp-getopt+.sh
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
      -f|--files) output_filter=cat;;
      -d|--dirs) output_filter=test_dir_only;;
      -p|--full-path|--path) output_filter=full_path;;
      --real-path|--rp) output_filter=real_path;;
      -s|--status-regexp|--sre) shift; status_regexp="${1}";;
      --srv|--status-not-regexp|--not-status-regexp|--status-regexp-v) shift; status_regexp="${1}"; invert_flag='-v';;
      --not-running|--done|--exited|--finished) status_regexp="^(RUNNING|NOTRUN)"; invert_flag='-v';;
      --failed|--b0rked|--error|--fail) status_regexp="^(NOTRUN|RUNNING|PASS_(GOLD|LEAD))"; invert_flag='-v';;
      --no-failed|--not-b0rked|--not-error|--not-fail) status_regexp="^(NOTRUN|RUNNING|PASS_(GOLD|LEAD))";;

      --passed|--success|--good|--pass) status_regexp="^(PASS_(GOLD|LEAD))";;
      --running) status_regexp="^RUNNING";;
      --not-done) status_regexp="^(RUNNING|NOTRUN)";;
      --in-file|--in|--if) shift; in_file="${1}";;
      --nth|--run-num) shift; run_num="${1}";;
      # Help!
      --help) Usage; exit 0;;
      --) shift ; break ;;
      *) echo 1>&2 "Unsupported option>$1<"
         exit 1;;
    esac
    shift
done

EExec_verbose_echo_id output_filter

test_dir_only()
{
    sed -rn 's!(.*)(/[^/]*$)!\1!p'
}

: ${test_dir:=$(tgen-latest-run --run-num "${run_num}" --test-dir ${test_name_opt})}
rel_test_dir=$(realpath -r "${test_dir}")

full_path()
{
    sed -rn "s!tests/!${rel_test_dir}/tests/!p" | test_dir_only
}

real_path()
{
    sed -rn "s!tests/!${rel_test_dir}/tests/!p" | dp-realpath -v
#    dp-realpath -v
}

num_lines=0
OPWD="${PWD}"
EExec -y cd $(me-expand-dest "testgen")
echo "Getting status for ${test_dir}"

if vsetp "${in_file}"
then
    tmp_file="${in_file}"
else
    EExec ./batch_status "${test_dir}" >| "${tmp_file}"
fi

EExec cat "${tmp_file}" | EExec "${output_filter}" \
            | EExec egrep ${invert_flag} "${status_regexp}"
EExec_verbose_msg "Total number of lines: $(wc -l ${tmp_file})"
rc=$?

# Let the exit handler do this.
#rm -f "${tmp_file}"
#tmp_file=

exit $rc
