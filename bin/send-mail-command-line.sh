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

on_error()
{
    local rc="${1-}"; shift

    echo "on_exit: rc: $rc; ${trap_exit_msg}"
    trap '' 0
}

#
# template ends.
########################################################################

MAIL_POSSIBILITIES="mail mutt"

: ${mailer=$($HOST_INFO -n mutt command-line-mailer )}
find_mailer()
{
    for m in "${mailer}" ${MAIL_POSSIBILITIES}
      do
      type -t "${m}" >/dev/null 2>&1 && {
          echo "${m}"
          return 0
      }
    done
}
m=$(find_mailer) || {
    echo "Cannot find a command line mailer."
    exit 1
} 1>&2

EExec "${m}" "$@"
