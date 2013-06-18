#!/bin/sh

set -x

: ${testname:=cpu_surface_write_read}
: ${testext=.so}
: ${rundir:=$(depth)}
: ${EZEC=}
: ${dump_waves_opt=}

for i in "$@"
do
  case "${1}" in
      -n) EZEC=echo;;
      -w|--wave|--waves|-wave|-waves) dump_waves_opt=-waves;;
      *) break;;
  esac
  shift
done

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

pwd
${EZEC} ./bin/system_run \
    -mode arm \
    ${dump_waves_opt} \
    -P t124 \
    -dir "${logdir}" \
    -o "${logfile}" \
    -noClean \
    -traces "${trace_dir}" \
    -mods "-top -cpu_rtl -pitch -zt_count_0 -i ${hdr_file} -o TestDir/${testname} -plugin '${testname} num_lines=2 default_door no_check_mem_reg'" \
    "${testname}${testext}" \
    -v top_peatrans_gpurtl
