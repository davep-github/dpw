#!/bin/sh
#set -x
# Programming when you're bored and have nothing else to do can result in
# overly baroque and incomprehensible code.  Tsk.
source script-x
$DP_SCRIPT_X_DASH_X_OFF

ORIG_ARGS=("$@")

MOTD=/etc/motd
[ -w "${MOTD}" ] || {
    MOTD=/dev/null
}
#MOTDer="/home/davep/bin.Linux.i686/lcursive"
MOTDer="figlet"
cleanup_sep='!!!! Do not Forget New Kernel Cleanup (try: new-kernel-fini) !!!!'
timestamp="$(dp-std-timestamp).$$"
: ${log_dir:="$PWD/,bk.log,"}
: ${proscribed_branches_default:=master}
: ${proscribed_branches_extra:=}
: ${proscribed_branches:=${proscribed_branches_default} ${proscribed_branches_extra}}

mkdir -p "${log_dir}" || exit 1

#
# find the build root.
#
[ -d "${linuxdevroot}" ] || {
    linuxdevroot=$(find-up Documentation) && {
	linuxdevroot="$(dirname ${linuxdevroot})"
    }
}

if test -d "${linuxdevroot}"
then
    cd "${linuxdevroot}"
    test -d Documentation
fi || {
   echo 1>&2 "${linuxdevroot} doesn't look like a linux source dir."
   exit 1
}

echo "Building in>$(pwd)<"

build_dir=$(basename $(realpath .))
bw_log="$log_dir/bw.out-$build_dir.$timestamp"
bk_log="$log_dir/bk.out-$build_dir.$timestamp"
bwk_log="$log_dir/bwk.out-$build_dir.$timestamp"
: ${bk_serial_num_file:=bk-serial-num}
: ${serialize_kernels_p=}
: ${xyopp_p=}
ok_file=/tmp/bk.sh.banner-OK.$$
fail_file=/tmp/bk.sh.banner-FAIL.$$
stat_files="$ok_file $fail_file"
# make: clean, kernel, modules_install, install
all_actions="ckmi"
: ${action_list_modules="modules modules_install"}
: ${action_list_bk="build_kernel ${action_list_modules} install"}
: ${action_list_all="clean ${action_list_bk}"}
# Useful default for kernel dev.
: ${action_list=${action_list_modules}}
: ${what_am_i_doing_p=}
#echo "0: actions>$actions<"
#echo "1: actions>$actions<"
NUM_CPUS=$(num-cpus)
NUM_JOBS=$((NUM_CPUS - 1))
MAKE_OPTIONS="-j${NUM_JOBS}"
MAKE_CMD="make ${MAKE_OPTIONS}"
dash_n=
mk_header_p=t
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
    echo 1>&2 "canon... @>$@<"
    echo 1>&2 "canon... @>$@<"
    echo "canon... $(echo_id op)"
    echo "canon... $(echo_id op)"
    case "$op" in
	c*) echo "clean";;
	[bk]*) echo "build_kernel";;
	M*) echo "modules_install";;
	m*) echo "modules";;
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
	echo 1>&2 "canon...list $(echo_id op)"
	clist="$clist $(canonicalize $op)"
    done
    echo "$clist"
}

$DP_SCRIPT_X_DASH_X_ON
while (($# > 0))
do
  case "$1" in
      --make) genkernel_p=; shift; break;;
      --genk*) genkernel_p=t; break;;
      --all) action_list="${action_list_all}";;
      --dev|--mod|--mods|--modules) action_list="${action_list_modules}";;
      --mii) action_list="modules_install install";;
      --bk) action_list="${action_list_bk}";;
      --xyopp|--yopp|--xy) xyopp_p=t;;
      --no-xyopp|--no-yopp|--no-xy) xyopp_p=;;
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
                  w) what_am_i_doing_p=t;;
                  n) dash_n=y;;
                  N) dash_n=y; mk_header_p=;;
                  s) serialize_kernels_p=t;;
                  z) action_list=;;
                  M) action_list=modules_install;;
                  m) action_list=modules;;
                  a) action_list="${action_list_all}";;
                  d) action_list="${action_list_modules}";;
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

vsetp "${what_am_i_doing_p}" && {
    echo "actions>${actions}<"
    exit 0
}

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

print_error()
{
    local rc="${1}"
    shift
    echo 1>&2 "print_error: rc>$rc<"
    if [ "$rc" = 0 ]
    then
	echo "SUCCESS"
    else
        echo -n "FAILURE: "
	if ((rc > 127))
	then
	    echo "SIGNAL: $((rc - 128))"
	else
	    echo "rc: $rc"
	fi
    fi
}

caught_signal()
{
    local rc="$?"; shift
    local exit_msg="${@}"

    # Do this before anything that could possibly fail.
    cleanup
    #set -x
    echo 1>&2 "
caught_signal: ${exit_msg}"
    print_error 1>&2 "${rc}"
    exit "${rc}"
}

for sig in 2 3 4 5 6 7 8 15
do
      trap "caught_signal $sig, $0: sig: $sig, exiting." "${sig}"

  #trap "echo; echo $0: Got sig $sig, exiting.; cleanup; exit $((128+$sig))" \
  #    $sig
done

# Useful traps
on_exit()
{
    local rc="$?"
    echo 1>&2 "on_exit: rc>$rc<"
    local exit_msg="${@}"; shift

    echo 1>&2 "
EXIT: rc: $rc; exit_msg>${exit_msg}<"
    print_error 1>&2 "${rc}"
}
###trap 'on_exit' 0
sig_exit=EXIT
trap "on_exit $0: sig: ${sig_exit}, exiting." "${sig_exit}"

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
ORIG_ARGS: ${ORIG_ARGS[@]}
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
git status -uno:'
        git --no-pager status -uno
        echo '#############################################################################
git log:'
        git --no-pager log -n 5 --pretty=short
        echo '#############################################################################
git branch:'
        git branch
	current_branch=$(git-raw-branch-names)
	for b in ${proscribed_branches}
	do
	    if [ "$b" = "${current_branch}" ]
	    then
		echo 1>&2 "Error, refusing to build proscribed branch ${current_branch}. 
  Proscribed branches: ${proscribed_branches}"
		exit 1
	    fi
	done
        echo '#############################################################################
this file:'
        echo $bk_log
    fi
}

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

    #missing exit code {
    #missing exit code 	echo; echo; echo -n "********** "
    #missing exit code 	read -e -p "Waiting..."
    #missing exit code 	echo "REPLY>${REPLY}<"

    #missing exit code 	ret="${REPLY:-99}"
    #missing exit code 	echo "exit ${ret}'ing."; exit "${ret}"
    #missing exit code } 1>&2
    target="$@"
    target_name="${target}"
    if [ "${target}" = 'kernel' ]
    then
        # make kernel doesn't do what it used to.
        # However, make w/o target DTRT.
        target_name="~kernel~"
        target=
    fi
    echo "***** making: ${target_name}..." \
        && \
        do_cmd $sudo ${MAKE_CMD} ${target} || {
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
          modules_install) echo "$a: modules_install."; mk_target --sudo modules_install;;
          modules) echo "$a: modules."; mk_target modules;;
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

    [ -n "${mk_header_p}" ] && write_log_header >> $bk_log
    
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
        [ -n "${xyopp_p-}" ] && {
            cat "${ok_file}" | xyopp -
        }
    else
        cat $fail_file
        [ -n "${xyopp_p-}" ] && {
            cat "${fail_file}" | xyopp -
        }
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

# This was for finding problems from the Ryzen micro-op cache bug.
# I've a good Ryzen and this returns too many false positives.
#error_regexp= "segfault|segmentation|internal|error: "
error_regexp="segfault: "
if [ -n "${error_regexp}" ]
then
    error_grep_cmd="--error-grep ${error_regexp}"
else
    error_grep_cmd=
fi
#echo_id error_grep_cmd
build_kernel 2>&1 | teeker -si 1 \
    --verbose-grep-summary \
    ${error_grep_cmd} \
    -a \
    ${bk_log}
echo "BK done: $(date)"

#/home/davep/bin.Linux.i686/lcursive
