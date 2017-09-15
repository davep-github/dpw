#!/bin/bash
#
# Originally written to create bash history files.  Hence the default values.
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

trap_exit_msg=

# Useful traps
on_exit()
{
    local rc="$?"
    local signum="${1-}"; shift

    echo "on_exit: rc: $rc; ${trap_exit_msg}"
}

on_error()
{
    local rc="${1-}"; shift

    echo "on_exit: rc: $rc; ${trap_exit_msg}"
    trap '' 0
}

: ${DOT=}
: ${creat_p=t}
: ${persist_p=}
: ${mkdir_only_p=}
: ${use_project_as_a_prefix=}
: ${prefix=}

persist=
true_p "${persist_p}" && persist=persist/

while (($# > 0))
do
  case "${1}" in
      --use-project-as-a-suffix|--projsuff|--ups)
    echo_id PROJECT
            prefix="${PROJECT-brahma}"; prefix=".${prefix}";;
      --prefix) shift; prefix="${1}";;
      --) shift; break;;
      *) break;;
  esac
  shift
done


dir_name="$HOME/droppings/${persist}${DOT}${1-bash-history}"
true_p "${creat_p}" || true_p "${mkdir_only_p}" && mkdir -p "${dir_name}"
true_p "${mkdir_only_p}" && exit
name="${dir_name}/${HOSTNAME}${prefix}"
echo "${name}"
