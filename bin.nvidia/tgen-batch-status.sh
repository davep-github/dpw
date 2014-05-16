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

option_str="t:r:fd"
long_options=(
    "test:" "test-name:"
    "test-dir:" "test-root:"
    "files"
    "dirs"
)

test_name_opt=
test_dir=
output_filter=test_dir_only

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
EExec -y cd $(me-expand-dest "testgen")
echo "Getting status for ${test_dir}"
EExec ./batch_status "${test_dir}" | "${output_filter}"

