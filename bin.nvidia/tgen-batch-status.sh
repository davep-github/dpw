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

# Useful traps
on_exit()
{
    local rc="$?"
    local signum="${1-}"; shift

    echo "on_exit: rc: $rc; ${cron_opt}"
}

on_error()
{
    local rc="${1-}"; shift

    echo "on_exit: rc: $rc; ${cron_opt}"
    trap '' 0
}

: ${status_regexp=.*}

option_str="t:r:fdps:"
long_options=(
    "test:" "test-name:"
    "test-dir:" "test-root:"
    "files"
    "dirs"
    "full-path"
    "status-regexp:"
    "srv" "status-not-regexp" "not-status-regexp" "status-regexp-v"
    "not-running" "done" "exited" "finished"
)

test_name_opt=
test_dir=
output_filter=test_dir_only
invert_flag=

source dp-getopt+.sh
while (($# > 0))
do
  # do. e.g.  shift; $OPTION_ARG=$1;; # to process options with arguments.
  case $1 in
      # eexec support
      # Done by EExec_parse and friends.

      # Program options.
      -t|--test|--test-name) shift; test_name_opt="--test-name ${1}";;
      -r|--test-dir|--test-root) shift; test_dir="${1}";;
      -f|--files) output_filter=cat;;
      -d|--dirs) output_filter=test_dir_only;;
      -p|--full-path) output_filter=full_path;;
      -s|--status-regexp) shift; status_regexp="${1}";;
      --srv|--status-not-regexp|--not-status-regexp|--status-regexp-v) shift; status_regexp="${1}"; invert_flag='-v';;
      --not-running|--done|--exited|--finished) status_regexp="^RUNNING"; invert_flag='-v';;
      # Help!
      --help) Usage; exit 0;;
      --) shift ; break ;;
      *) echo 1>&2 "Unsupported option>$1<"
         exit 1;;
    esac
    shift
done

test_dir_only()
{
    sed -rn 's!(.*)(/[^/]*$)!\1!p'
}

: ${test_dir:=$(tgen-latest-run --test-dir ${test_name_opt})}
rel_test_dir=$(realpath -r "${test_dir}")

full_path()
{
#    read
#    set -- $REPLY
#    # PASS_GOLD     d1b4649ac4e62e7cf56037a5cee63004     tests/non3d_maxwell_dma_copy_a_directed_sanity/00/03/36/000336/sema1
#    echo $REPLY | sed -rn "s!$3!${test_dir}${3}!p" | test_dir_only
    sed -rn "s!tests/!${rel_test_dir}/tests/!p" | test_dir_only
}

EExec -y cd $(me-expand-dest "testgen")
echo "Getting status for ${test_dir}"
EExec ./batch_status "${test_dir}" | "${output_filter}" | egrep ${invert_flag} "${status_regexp}"
