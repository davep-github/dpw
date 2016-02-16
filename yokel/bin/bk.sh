#!/bin/sh
#set -x
# Programming when you're bored and have nothing else to do can result in
# overly baroque and incomprehensible code.  Tsk.
source script-x
$DP_SCRIPT_X_DASH_X_OFF

MOTD=/etc/motd
[ -w "${MOTD}" ] || {
    MOTD=/dev/null
}
#MOTDer="/home/davep/bin.Linux.i686/lcursive"
MOTDer="figlet"
cleanup_sep='!!!! Do not Forget New Kernel Cleanup (try: new-kernel-fini) !!!!'
timestamp="$(dp-std-timestamp).$$"
: ${log_dir:="$PWD/,bk.log,"}
mkdir -p "${log_dir}" || exit 1
build_dir=$(basename $(realpath .))
bw_log="$log_dir/bw.out-$build_dir.$timestamp"
bk_log="$log_dir/bk.out-$build_dir.$timestamp"
bwk_log="$log_dir/bwk.out-$build_dir.$timestamp"
: ${bk_serial_num_file:=bk-serial-num}
: ${serialize_kernels_p=}
ok_file=/tmp/bk.sh.banner-OK.$$
fail_file=/tmp/bk.sh.banner-FAIL.$$
stat_files="$ok_file $fail_file"
# make: clean, kernel, modules_install, install
all_actions="ckmi"
: ${action_list_all="clean build_kernel modules_install install"}
# Useful default for kernel dev.
: ${action_list_dev="build_kernel modules_install install"}
: ${action_list=${action_list_dev}}
#echo "0: actions>$actions<"
#echo "1: actions>$actions<"
dash_n=
if [ "$HOST" = "vilya" ] 
then
    ${genkernel_p=t}
else
    ${genkernel_p=}
fi

[ "${serialize_kernels_p}" = 't' ] && {
    [ -e "${bk_serial_num_file}" ] || {
        echo 0 >| "${bk_serial_num_file}"
    }

    # For backup .config file name (sed -i)
    old_serial_num=$(cat "${bk_serial_num_file}")
    serial_num=$((old_serial_num + 1))
    bk_log="${bk_log}.${serial_num}"
}
config_file=.config

fix_realtek()
{
    do_cmd cd ${brahmaec}/cz-stuff/realtek
    pwd
    do_cmd ./autorun.sh
}

canonicalize()
{
    local op=$1
    #echo 1>&2 "canon... @>$@<"
    #echo 1>&2 "canon... $(echo_id op)"
    case "$op" in
	c*) echo "clean";;
	[bk]*) echo "build_kernel";;
	m*) echo "modules_install";;
	i*) echo "install";;
        d*) echo "dev ops";;
	*) echo 1>&2 "Bogus: $(echo_id op)"
	    exit 1;;
    esac
}

canonicalize_list()
{
    local clist=""
    for op in "$@"
    do
	#echo 1>&2 "canon...list $(echo_id op)"
	clist="$clist $(canonicalize $op)"
    done
    echo "$clist"
}

$DP_SCRIPT_X_DASH_X_ON
while (($# > 0))
do
  case "$1" in
      --make) genkernel_p=; break;;
      --genk*) genkernel_p=t; break;;
      --all) action_list="${action_list_all}"; break;;
      --dev) action_list="${action_list_dev}"; break;;
      --) break;;
      -*)
            # Nukes leading `-' from the option.
            ops=$(echo -- "$1" | sed -r 's/^([[:space:]]*)(--)([[:space:]]+)(-)(.+)/\5/')
            # Splits >1 option char into string of option chars.
            ops=$(echo $ops | sed -r 's/(.)/\1 /g')
            for op in $ops
            do
	      #echo_id 1>&2 op
	      #echo_id 1>&2 action_list
              case "${op}" in
                  n) dash_n=y;;
                  s) serialize_kernels_p=t;;
                  z) action_list=;;
                  m) action_list=modules_install;;
                  a) action_list="${action_list_all}";;
                  d) action_list="${action_list_dev}";;
                  *) action_list="$action_list $(canonicalize $op)";;
              esac
            done
            ;;
  esac
  shift
done
#echo_id 1>&2 action_list

vsetp "${genkernel_p}" && {
    genkernel "$@"
    exit
}

# Add space for checking entire action in been_done list
actions=" $action_list $(canonicalize_list $@) "	

vsetp "$dash_n" && {
    echo "dash_n>$dash_n<"
    echo "actions>$actions<"
    bw_log="/dev/tty"
    bk_log="/dev/tty"
    bwk_log="/dev/tty"
}

bk_done='-_-_-_-_-bk.sh DONE \\/\\/\\/\\/\\/\\/\\/\\/ DONE bk.sh_-_-_-_-'
action_error()
{
    echo 1>&2 "Bad action code: $*"
    echo 1>&2 "  must be in set: [$all_actions]."
    exit 1
}

cleanup()
{
    rm -f $stat_files
}

exit_sig()
{
    rc=$1
    cleanup
    echo -n 1>&2 "
EXIT: "
    if [ "$rc" = 0 ]
    then
    echo 1>&2 "SUCCESS"
    else
        echo 1>&2 "FAILURE: $rc"
    fi
    exit $rc
}
    
# Verify each command char.
#action_set="[$all_actions]"
#for a in $actions
#do
#  [[ $a == $action_set ]] || action_error $a
#done

if type banner >/dev/null 2>&1
then
    banner OK >| $ok_file
    banner FAIL >| $fail_file
else
    echo "OK OK OK" >| $ok_file
    echo "FAIL FAIL FAIL" >| $fail_file
fi

write_log_header()
{
    echo "Build begins: ${timestamp}:
id:
$(id)
in PWD:
$PWD
realpath of PWD:
$(realpath $PWD)
fs info:
$(df -h .)
"
    if [ -e Makefile ] && gitted -q Makefile
    then
        echo '#############################################################################
git status:'
        git --no-pager status
        echo '#############################################################################
git log:'
        git --no-pager log -n 5 --pretty=short
        echo '#############################################################################
git branch:'
        git branch
        echo '#############################################################################
this file:'
        echo $bk_log
    fi
}

for sig in 2 3 4 5 6 7 8 15
do
  trap "echo; echo $0: Got sig $sig, exiting.; cleanup; exit $((128+$sig))" \
      $sig
done
trap "exit_sig \$?" EXIT

bk_freebsd()
{
    USER=theoden make buildkernel
}

do_cmd()
{
    local sudo=
    local sudo_str=
    if [ "$1" = '--sudo' ]
    then
        sudo=sudo
        sudo_str="sudo "
        shift
    fi
    if [[ $dash_n == [yY1tT] ]]
    then
        echo "-- ${sudo_str}$@"
        true
    else
        echo "++ ${sudo_str}$@"
        $sudo "$@"
    fi
}

mk_target()
{
    local sudo=
    if [ "$1" = '--sudo' ]
    then
        sudo=sudo
        shift
    fi
    target="$@"
    target_name="${target}"
    if [ "${target}" = 'kernel' ]
    then
        # make kernel doesn't do what it used to.  
        # However, make w/o target DTRT.
        target_name="~kernel~"
        target=
    fi
    echo "***** making: ${target_name}..." && do_cmd $sudo make ${target} || {
        echo 1>&2 "***** make ${target_name} failed, \$?: $?"
        exit 1
    }
    echo "made ${target_name}."
}

remove_cmd()
{
    local cmd="$1"
    shift
    cmds="$@"
    echo $cmds | sed -r "s/$cmd//g"
}

build_kernel_target()
{
    # CONFIG_LOCAL_VERSION="-edc.dp"
    if [ "${serialize_kernels_p}" = 't' ]
    then
        local new_ver=-edc.${serial_num}
        local old_ver=-edc.${old_serial_num}
        sed -i".${old_ver}" -rn "s/(CONFIG_LOCAL_VERSION=)(.*)/\1${new_ver}/p" "${config_file}"
    fi
    mk_target kernel
    # Inc version number if make succeeded.
    if [ "${serialize_kernels_p}" = 't' ]
    then
        echo "${serial_num}" >| "${bk_serial_num_file}"
    fi
}

bk_linux()
{
    vsetp $dash_n && echo_id actions
    local been_done=""
    for a in $actions
    do
	vsetp $dash_n && {
	    echo_id been_done
	    echo_id a
	}
	[[ "$been_done" == *\ $a\ * ]] && {
	    vsetp $dash_n && echo "$a: Already been done."
	    continue
	}

      case "$a" in
          c*) echo "$a: clean."; mk_target clean;;
          [bk]*) echo "$a: build_kernel."; build_kernel_target;;
          m*) echo "$a: modules_install."; mk_target --sudo modules_install;;
             # make install not specified in gentoo build guide
          i*) echo "$a: install."; mk_target --sudo install ;;
          *) action_error $a;;
      esac
      been_done="$been_done $a "

    done
    echo "bk_linux complete. $(echo_id been_done)"
}

build_kernel()
{
    echo "Requested actions: \"$actions\""

    write_log_header() >> $bk_log
    
    if [ "$OSName" = "FreeBSD" ]
    then
        bk_freebsd
    else
        bk_linux
    fi
    rc=$?
    if [ "$rc" = '0' ]
    then
        cat $ok_file
    else
        cat $fail_file
        bk_done="!FAILED! $bk_done FAILED!"
        echo "rc: $rc"
    fi
    case "${PWD}" in
        NOT_NOW*brahma*) fix_realtek;;
        *) ;;
    esac
    echo "$bk_done"
    if [ "$rc" = 0 ]
    then
        {
            echo "$cleanup_sep"
            echo; echo; echo
            $MOTDer "New Kernel Fini"
            echo; echo;
            $MOTDer "X Drivers \!\!\!"
            echo; echo;
            $MOTDer "module-rebuild"
            echo; echo; echo
            echo "$cleanup_sep"
        } >| $MOTD
        echo "$bk_done"
    fi

}

build_kernel 2>&1 | tee -a $bk_log
echo "BK done"

#/home/davep/bin.Linux.i686/lcursive
