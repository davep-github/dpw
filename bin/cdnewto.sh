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
unset eexec_program
# Or export eexec_program to propagate eexec info to a called program.
# export eexec_program

while (($# > 0))
do
  case "$1" in
    --) shift; break;;
    *) break;;
  esac
  shift
done

stop_glob=("$@")
EExec_verbose_msg "stop_glob>${stop_glob[@]}<"
last_dir=
EExec_verbose_echo_id PWD
 while ! ls -d "${stop_glob[@]}" 1>/dev/null 2>&1
do
  cd_newest || exit
  [ "${PWD}" = "${last_dir}" ] && {
      EExec_verbose_echo_id PWD
      EExec_verbose_echo_id last_dir
      echo "End of the line."
      exit 1
  } 1>&2
  EExec_verbose_msg "PWD>$PWD<"
  last_dir="${PWD}"
done
 EExec_verbose_echo_id PWD
echo "${PWD}"
