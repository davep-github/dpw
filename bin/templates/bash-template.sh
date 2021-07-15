########################################################################
#
# BASH template begin.
# @todo XXX Can this work with ZSH, too?
#
banner "
Explain the name. e.g. cx --> Change file to be eXecutable.
cx was a *very* early first script.  Copped from Kerighan and Pike.
Knowing the name can help you to remember what it does.
Add a short comment about what this script does.
Like:
Makes text file into a script by making it executable.
"
exit 88

# There's a problem with telling if I'm a bash script.
# SHELL says zsh.
# DP_BASH_p is fucked up.  And I'm in too much of a hurry.
# "${DP_BASH_p-false}" || {
#     echo "[ as of: 2021-07-02T11:24:08 ], this isn't know to work with zsh."
#     exit 1
# } 1>&2

# davep specific code begin -------------8><------------------
source script-x
set -u
progname="$(basename $0)"
source eexec
if [[ -n "${eexec_program-}" ]] # Did the caller provide a program?
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

# davep specific code end  -------------8><------------------

#mutually exclusive with real EExec# EExec=''
#mutually exclusive with real EExec# no_exec_p=''
#mutually exclusive with real EExec# exec_verbose_p=''
#mutually exclusive with real EExec# Non_EExecer()
#mutually exclusive with real EExec# {
#mutually exclusive with real EExec#     {
#mutually exclusive with real EExec# 	echo "{-} $@"
#mutually exclusive with real EExec#     } 1>&2
#mutually exclusive with real EExec# }

#mutually exclusive with real EExec# Verbose_EExecer()
#mutually exclusive with real EExec# {
#mutually exclusive with real EExec#     {
#mutually exclusive with real EExec# 	echo "{+} $@"
#mutually exclusive with real EExec# 	"$@"
#mutually exclusive with real EExec#     } 1>&2
#mutually exclusive with real EExec# }

#mutually exclusive with real EExec# if [[ -n "${no_exec_p}" ]]
#mutually exclusive with real EExec# then
#mutually exclusive with real EExec#     EExec="Non_EExecer"
#mutually exclusive with real EExec# elif [[ -n "${exec_verbose_p}" ]]
#mutually exclusive with real EExec# then
#mutually exclusive with real EExec#     EExec=Verbose_EExecer
#mutually exclusive with real EExec# else
#mutually exclusive with real EExec#     EExec=''
#mutually exclusive with real EExec# fi


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

