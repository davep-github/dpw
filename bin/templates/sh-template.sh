source script-x
set -u
progname="$(basename $0)"
source eexec
if vsetp "${eexec_program-}"    # Did the caller provide a script?
then
    EEXEC_SHIFT=:
else
    eexec_script=$(EExec_parse "$@")
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

