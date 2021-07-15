#!/bin/bash
#
# Originally written to create bash history files.  Hence the default values.
#
# This file is used by both bash and zsh early in the shell startup.
# *HISTFILE aren't needed during init, so it should be possible to move them
# to the end of bashrc.
source script-x
set -u
progname="$(basename $0)"
source eexec
if [ -n "${eexec_program-}" ]    # Did the caller provide a program?
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
EExec_verbose_echo_id eexec_program
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
: ${creat_p=true}
: ${persist_p=false}
: ${mkdir_only_p=false}
: ${use_project_as_a_prefix=}
: ${prefix=}
: ${persist=}
: ${persist_dir=persist}

prefix=
suffix=
while (($# > 0))
do
    EExec_verbose_msg "1>${1}<"
    case "${1}" in
	--use-project-as-suffix|--projsuff|--ups)
	    # I need to fix how I specify empty locales.
	    [[ "${PROJECT}" == '-' ]] && PROJECT=NO_PROJECT
            suffix="${PROJECT-brahma}"; suffix=".${suffix}"
	    ;;
	--create?) creat_p=true;;
	--no-create?) creat_p=false;;
	--mkdir-only-p) mkdir_only_p=true;;
	--no-mkdir-only-p) mkdir_only_p=false;;
	--use-project-as-prefix|--projpre|--upp)
            prefix="${PROJECT-brahma}"; prefix="${prefix}.";;
	--use-tty-as-suffix) suffix=".$(tty_as_suffix)";;
	--prefix) shift; prefix="${1}";;
	--suffix) shift; suffix="${1}";;
	--persist) persist_p=true;;
	--persist-to|--persist-dir) shift; persist_dir="${1}";;
	--name_only|--no) creat_p=false; mkdir_only_p=false;;
	--) shift; break;;
	*) break;;
    esac
    shift
done

$persist_p && persist_dir="${persist_dir}/"


dir_name="$HOME/droppings/${persist}${DOT}${1-bash-history}"
$creat_p || $mkdir_only_p && mkdir -p "${dir_name}"
$mkdir_only_p && exit
name="${dir_name}/${prefix}${HOSTNAME}${suffix}"
echo "${progname}: $(date): name>${name}<" >> "/tmp/${progname}.log"
echo "${name}"
