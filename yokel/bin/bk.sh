#!/bin/sh
#set -x
source script-x
$DP_SCRIPT_X_DASH_X_OFF

MOTD=/etc/motd
#MOTDer="/home/davep/bin.Linux.i686/lcursive"
MOTDer="figlet"
cleanup_sep='!!!! Do not Forget New Kernel Cleanup (try: new-kernel-fini) !!!!'
date="$(dp-std-date).$$"
: ${log_dir:="/var/log/bk"}
mkdir -p "${log_dir}" || exit 1
build_dir=$(basename $(realpath .))
bw_log="$log_dir/bw.out-$build_dir.$date"
bk_log="$log_dir/bk.out-$build_dir.$date"
bwk_log="$log_dir/bwk.out-$build_dir.$date"
ok_file=/tmp/bk.sh.banner-OK.$$
fail_file=/tmp/bk.sh.banner-FAIL.$$
stat_files="$ok_file $fail_file"
# make: clean, kernel, modules_install, install
all_actions="ckmi"
action_list="clean kernel modules_install install"
: ${def_actions:="ckmi"}
##### non needed for new style actions=${1:-$def_actions}
#echo "0: actions>$actions<"
#echo "1: actions>$actions<"
dash_n=
if [ "$HOST" = "vilya" ] 
then
    ${genkernel_p=t}
else
    ${genkernel_p=}
fi

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
      --make) genkernel_p=;;
      --genk*) genkernel_p=t;;
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
	        [ "$op" = "n" ] && { dash_n=y; continue; }
	        action_list="$action_list $(canonicalize $op)"
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

{
    date
    pwd
}    >> $bk_log

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
    if [[ $dash_n == [yY1tT] ]]
    then
        echo 1>&2 "+ $@"
    else
        "$@"
    fi
    return 0
}

mk_target()
{
    target="$@"
    echo "***** making: ${target}..." && do_cmd make $target || {
        echo 1>&2 "***** make ${target} failed, \$?: $?"
        exit 1
    }
}

remove_cmd()
{
    local cmd="$1"
    shift
    cmds="$@"
    echo $cmds | sed -r "s/$cmd//g"
}
num=0
bk_linux()
{
    vsetp $dash_n && echo_id actions
    # @todo make this cross-linux
    bk_log=~davep/log-files/linux-kernel-build/$bk_log
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
          [bk]*) echo "$a: build_kernel."; mk_target;;
          m*) echo "$a: modules_install."; mk_target modules_install;;
             # make install not specified in gentoo build guide
          i*) echo "$a: install."; mk_target install ;;
          *) action_error $a;;
      esac
      been_done="$been_done $a "

    done
    echo "bk_linux complete. $(echo_id been_done)"
}

build_kernel()
{
    echo "Requested actions: \"$actions\""
    
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
        *brahma*) fix_realtek;;
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
