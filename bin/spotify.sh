#!/usr/bin/env bash
########################################################################
#
# template begin.

# davep specific code -------------8><------------------
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

# davep specific code -------------8><------------------

#mutually exclusive with real EExec# EExec=
#mutually exclusive with real EExec# no_exec_p=
#mutually exclusive with real EExec# Non_EExecer()
#mutually exclusive with real EExec# {
#mutually exclusive with real EExec#     echo "{-} $@" 1>&2
#mutually exclusive with real EExec# }

#mutually exclusive with real EExec# Verbose_EExecer()
#mutually exclusive with real EExec# {
#mutually exclusive with real EExec#     echo "{+} $@"
#mutually exclusive with real EExec#     "$@"
#mutually exclusive with real EExec# }

trap_exit_msg=

# Useful traps
on_exit()
{
    local rc="$?"
    local signum="${1-}"; shift

    echo "on_exit: rc: $rc; ${trap_exit_msg}"
}
# trap 'on_exit' 0

on_error()
{
    local rc="${1-}"; shift

    echo "on_exit: rc: $rc; ${trap_exit_msg}"
    trap '' 0
}
# trap 'on_error' ERR

sig_exit ()
{
    {
        local sig_num=$1; shift
        echo
        echo "sig_exit, sig_num: $sig_num"
        exit 1
    } 1>&2
}

# for sig in 2 3 4 5 6 7 8 15
# do
#     trap "sig_exit $sig" $sig
# done

display_stderr()
{
    echo 1>&2 "$progname: $@"
}

status_msg()
{
    display_stderr "$@"
}

fatal_error()
{
    local error="${1}"
    shift
    display_stderr "$@"
    exit "${error}"
}

Usage_error()
{
    fatal_error 1 "$@"
}

#
# template end.
########################################################################

xit /snap/spotify/36/usr/share/spotify/spotify
