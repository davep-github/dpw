#!/bin/sh

: ${confirmation_response:="TRUST ME"}

: ${testname:=cpu_surface_write_read}
: ${test_params="mapping_mode=reflected default_door no_check_mem_reg series_len=4 num_series=1 test=rtmem-rtmem"}
: ${testext=.so}
: ${rundir:=$(depth)}
: ${EZEC=}
: ${dump_waves_opt=}
: ${no_run_p=}
: ${startrecord=}
: ${startrecord_opt=}
: ${project:=t132}

: ${rtl_log_file_history:=rtl-log-file-history}

for i in "$@"
do
  case "${1}" in
      -n|--pretend|--dry-run) EZEC=echo; no_run_p=t; set -x;;
      -v|--verbose) set -x;;
      -q|--quiet) set +x;;
      -k|--eko) EZEC=eko; no_run_p=t;;
      -s|--start|--startrecord|--start-record) shift; startrecord="${1}";;
      -w|--wave|--waves|-wave|-waves) dump_waves_opt=-waves;;
      -p|--proj|--project) shift; project="${1}";;
      *) break;;
  esac
  shift
done

[ -z "${no_run_p-}" ] && {
    [ "${any_shell_p-}" != "${confirmation_response}" ] && {
        test $(basename "${SHELL}") = tcsh || {
            echo "You are not in a c-shell.
At this time, it is recommended to run tests that environment.
> ssh localhost
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

echo "Rundir >$rundir<"

logdir="${PWD}/dp-rtl-tests/$(dp-std-timestamp)"
#logdir="${PWD}/dp-rtl-tests/abs-file-names"
logfile="${logdir}/${testname}.log"
mkdir -p "${logdir}" || {
    rc="${?}"
    echo "Cannot create logdir >$logdir<, RC: ${rc}"
    exit "${rc}"
} 1>&2

pushd "${rundir}"

[ -e "tree.make" ] || {
    echo "tree.make is not in this dir [$PWD]."
    echo "Are you in a testgen run dir?"
    exit 1
} 1>&2

trace_dir=$(abspath ../../arch/traces/mobile/traces/gpu_multiengine)
hdr_file=$(abspath ../../arch/traces/mobile/traces/gpu_multiengine/comp_one_tri_redline/test.hdr)

[ -n "${startrecord}" ] && {
    startrecord_opt="-rtlarg +startrecord+${startrecord}"
}

echo "${logfile}" >> "${rtl_log_file_history}"

${EZEC} ./bin/system_run \
    -mode arm \
    ${dump_waves_opt} \
    ${startrecord_opt} \
    -P "${project}" \
    -dir "${logdir}" \
    -o "${logfile}" \
    -noClean \
    -traces "${trace_dir}" \
    -mods "-top -cpu_rtl -pitch -zt_count_0 -i ${hdr_file} -o TestDir/${testname} -plugin '${testname} ${test_params}'" \
    "${testname}${testext}" \
    -v top_peatrans_gpurtl
