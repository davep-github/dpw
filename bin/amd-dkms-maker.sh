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

popcat()
{
    cat
}

stat_fun=true
stat_exit=true
stat_all()
{
    EExec sudo dkms status amdgpu-pro/$PRO_VER --all
}

nuke_fun=true
nuke_exit=true
nuke_all()
{
    EExec sudo dkms remove amdgpu-pro/$PRO_VER --all
}

: ${remove_p=t}
: ${install_p=t}
: ${popups=${DISPLAY-}}
: ${popper:=xmessage}           # Any replacement must be compatible w/xmessage.
while (($# > 0))
do
  case "$1" in
      --stat-all) stat_fun=stat_all; stat_exit=exit;;
      --nuke-all) nuke_fun=nuke_all; nuke_exit=exit;;
      --stat|stat-1st|stat-first) stat_fun=stat_all; stat_exit=true;;
      --nuke|--nuke-1st|--nuke-first) nuke_fun=nuke_all; nuke_exit=true;;
      --remove) remove_p=t;;
      --no-remove) remove_p=;;
      --) shift; break;;
      *) break;;
   esac
   shift
done

$stat_fun
$stat_exit
$nuke_fun
$nuke_exit

if [ -n "${remove_p}" ]
then
    status=$(sudo dkms status amdgpu-pro/$PRO_VER -k $(uname -r)) 
    echo "status>$status<"
    echo "${status}" | EExec sed -rn "s/(amdgpu-pro, ${PRO_VER}: )(.*)$/\2/p"

    EExec_verbose_echo_id status
    remove_p=
    case "${status}" in
        added) remove_p=;;
        "") echo "No status, not removing."
            remove_p=;;
        installed) remove_p=t;;
        *) remove_p=t;;
    esac
    if [ -n "${remove_p}" ]
    then
        echo "${status}"
        echo "Removing."
        # Man does this whole thing suck.  Accretion by too quick hacks from
        # a "simple" helper function.
        # starting as 'echo 'long-command-line' > script
        # quickie isn't.
        if [ "${1-}" = "--all" ]
        then
            rel="--all"
        else
            rel=$(uname -r)
        fi
        EExec sudo dkms remove amdgpu-pro/$PRO_VER -k "${rel}"
    else
        echo "Nothing to remove."
    fi
else
    echo "Removal not requested."
fi
rc=0
if [ -n "$install_p" ]
then
    EExec --no-exit sudo dkms install amdgpu-pro/$PRO_VER -k $(uname -r)
    rc=$?
    EExec_verbose_echo_id --pre 0th rc
    ((rc != 0)) && {
        EExec cat /var/lib/dkms/amdgpu-pro/17.30-464532/build/make.log
    }

    buttnum=
    #        101   ,102
    buttons="OK, reboot"
    fail_buttons="OK"               # Keep same button number for OK.
    popups=${DISPLAY-}
    if [ -n "${popups}" ]
    then
        EExec_verbose_echo_id --pre 1st rc
        if EExecDashN_p
        then
            stat="DEBUG"
            buttons="${fail_buttons}"
        elif ((rc != 0))
        then
            stat="FAIL"
            buttons="${fail_buttons}"
        else
            stat="SUCCESS"
        fi
        banner "$progname: ${stat}." | "${popper}" -buttons "${buttons}" -file -
        buttnum=$?
    
        raise-window "${popper}"
    fi

    EExec_verbose_echo_id buttnum

    [ "${buttnum}" = 102 ] && REBOOT=t
fi

((rc == 0)) && [ -n "${REBOOT-}" ] && sudo shutdown -r now

exit $rc
