#!/bin/sh

bindir=$(dirname "$0")

: ${confirmation_response:="TRUST ME"}

: ${testname:=cpu_surface_write_read}
: ${test_args="mapping_mode=reflected default_door no_check_mem_reg series_len=1 num_series=1 suite=rtmem-rtreg"}
: ${testext=.so}
: ${rundir:=$(depth)}
: ${EZEC=}
: ${dump_waves_opt=}
: ${no_run_p=}
: ${startrecord=}
: ${startrecord_opt=}
: ${project:=t124}
: ${RUN_CMD:=./bin/system_run}
: ${DENVER_RUN_CMD:=./bin/denver_system_run}
: ${DENVER_ARGS:=-denver_mts -rtapi_denver}
: ${denver_args=}
: ${run_cmd:=${RUN_CMD}}
: ${rtl_log_file_history:=rtl-log-file-history}

original_args=("$@")

while (($# > 0))
do
  case "${1}" in
      -n|--pretend|--dry-run) EZEC=echo; no_run_p=t; set -x;;
      -v|--verbose) set -x;;
      -q|--quiet) set +x;;
      -k|--eko) EZEC=eko; no_run_p=t;;
      -s|--start|--startrecord|--start-record) shift; startrecord="${1}";;
      -w|--wave|--waves|-wave|-waves) dump_waves_opt=-waves;;
      -P|--proj|--project|--chip) shift; project="${1}"; echo "project>${project}<";;
      -p|--prog|--program|--test|--test-name) shift; testname="${1}";;
      -a|--args|--prog-args|--program-args) shift; test_args="${1}";;
      -t|--traces|--trace-dir) shift; trace_dir="${1}";;
      -d|--denver) exec "${bindir}/tip-top-denver.sh" "${original_args[@]}";;
      -*) echo 1>&2 "Unsupported option-looking arg>${1}<";
          break;;
       *) break;;
  esac
  shift
done

echo "Remaining args: $@"

[ -z "${no_run_p-}" ] && {
    [ "${any_shell_p-}" != "${confirmation_response}" ] && {
        test $(basename "${SHELL}") = tcsh || {
            echo "You are not in a c-shell.
At this time, it is recommended to run tests that environment.
> ssh \$HOST
will get a pristine standard environment.
But if you insist on BASHing your test against the wall, 
set then environment variable any_shell_p to ${confirmation_response}"
            exit 1
        } 1>&2
    }
}

abspath()
{
    local path="${1}"
    ( cd $(dirname "${path}"); echo "${PWD}/$(basename ${path})" )
}

echo "Rundir >$rundir<, >$(cd $rundir; pwd)<"


logdir="${PWD}/dp-rtl-tests/$(dp-std-timestamp)"
#logdir="${PWD}/dp-rtl-tests/abs-file-names"
logfile="${logdir}/${testname}.log"
if [ -z "${no_run_p}" ]
then
    mkdir -p "${logdir}" || {
        rc="${?}"
        echo "Cannot create logdir >$logdir<, RC: ${rc}"
        exit "${rc}"
    }
else
    echo "Not running anything. Not making log dir."
fi 1>&2

pushd "${rundir}"

[ -e "tree.make" ] || {
    echo "tree.make is not in this dir [$PWD]."
    echo "Are you in a testgen run dir?"
    exit 1
} 1>&2


: ${trace_dir=../../arch/traces/mobile/traces/gpu_multiengine}
trace_dir=$(abspath "${trace_dir}")
: ${hdr_file=../../arch/traces/mobile/traces/gpu_multiengine/comp_one_tri_redline/test.hdr}
hdr_file=$(abspath "${hdr_file}")

[ -n "${startrecord}" ] && {
    startrecord_opt="-rtlarg +startrecord+${startrecord}"
}

echo "${logfile}" >> "${rtl_log_file_history}"
if [ -n "${test_args}" ]
then
    test_args=" ${test_args}"
fi

${EZEC} "${run_cmd}" \
    -P "${project}" \
    -mode arm \
    ${dump_waves_opt} \
    ${startrecord_opt} \
    ${denver_args} \
    -dir "${logdir}" \
    -o "${logfile}" \
    -noClean \
    -traces "${trace_dir}" \
    -mods "-top -cpu_rtl -pitch -zt_count_0 -i ${hdr_file} -o TestDir/${testname} -plugin '${testname}${test_args}'" \
    "${testname}${testext}" \
    -v top_peatrans_gpurtl
