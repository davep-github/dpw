#!/usr/bin/env bash
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
# template ends.
########################################################################
#
# Motivation: convert responses from multicast ping to host names.
# E.g.:
# > ping 224.0.0.1
# PING 224.0.0.1 (224.0.0.1) 56(84) bytes of data.
# 64 bytes from 192.168.114.31: icmp_req=1 ttl=64 time=1.07 ms
# 64 bytes from 192.168.115.95: icmp_req=1 ttl=64 time=1.44 ms (DUP!)

# This more better because it use /etc/hosts if nsswitch is configured
# aright.
do_getent()
{
    getent hosts "$@" | awk '{print $2}'
}

do_host()
{
    host "$@" | awk '{print $5}'
}

if type -t getent >/dev/null 2>&1
then
    resolver=do_getent
else
    resolver=do_host
fi

fgrep 'bytes from' \
| awk '{print $4}' \
| sed -rn 's/([^:]+)(:)/\1/p' \
| sort \
| uniq \
| while read
do
    "${resolver}" "${REPLY}"
done
