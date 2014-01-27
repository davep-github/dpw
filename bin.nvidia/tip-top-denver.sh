#!/bin/sh

vtruep()
{
    case "${1}" in
        [tT1]|true) return 0;
    esac
    return 1
}
: ${confirmation_response:="TRUST ME"}

: ${testname:=cpu_surface_write_read}
: ${test_args="mapping_mode=reflected default_door no_check_mem_reg series_len=1 num_series=1"}
suites=(rtmem-rtreg)
: ${testext=.so}
: ${rundir:=$(depth)}
: ${timestamp=$(dp-std-timestamp)}
: ${EZEC=}
: ${dump_waves_opt=}
: ${no_run_p=}
: ${startrecord=}
: ${startrecord_opt=}
: ${project:=t132}
: ${rtprint_opt=}
: ${ddd_opt=}
: ${debug_opt=}
: ${debug_level_opt=}
: ${printout_flag_p=}
: ${no_allow_errors_p=}
: ${no_elves_p=}
: ${no_csh_check_p=}
: ${elves='/home/denver/release/sw/components/mts/1.0/cl28625566/debug_arm/denver/bin/mts.elf@0xe0000000:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/drv/mpcore/t132/ObjLinux_MPCoreXC/boot_page_table.axf:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/override.elf@0xe0000000:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/t132/ObjLinux_MPCoreXC/cpu_surface_write_read.Cortex-A8.axf:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/t132/ObjLinux_ARM7TDMIXC/cpu_surface_write_read.ARM7TDMI.axf:'}

: ${config=top_peatrans_gpurtl} # Not for CPU? NO. Yes for MODS + CPU
#: ${config=top_gpurtl_t132} # ??? do I need the _t132? NO.
#: ${config=top_gpurtl} # ??? do I need the _t132? NO.

: ${mode_arg=-mode arm}
: ${RUN_CMD:=./bin/system_run}
T124_ARGS=()
: ${DENVER_RUN_CMD:=./bin/denver_system_run}

ALLOW_ERROR_ARGS=(
    -allow_error_string "ERROR: \(PLL24G_DYN_PRB_ESD\)  An error in SETUP or power is preventing the PLL from starting"
    -allow_error_string "0 demoted errors"
    -allow_error_string "DSIM Warning: DMTRR* applies to both secure and non-secure space; intentional\? failed\:"
    -allow_error_string "Verilog status: assertion\-errors\=0"
    -allow_error_string "WARNING : SCH FDIV state does not match FPS"
    -allow_error_string "Incorrect configuration for uncore pmc_counter"
    -allow_error_string "failed: file .*tlb_arm\.support"
    -allow_error_string "LS0 RdReq sent to L2 when there are no credits available"
    -allow_error_string "LS1 RdReq sent to L2 when there are no credits available"
    -allow_error_string "WARNING : ATB_ERRM_ATBHS. When ATVALID is asserted, ATVALID de-asserted before ATREADY asserted is not permitted."
    -allow_error_string "WARNING.*csite_datb_pc_checker"
    -allow_error_string "WARNING\s+:\s+NV_MC_tu\s+\(NV_MC_ASSERT_DEBUG_WARNING\)\s+client.*:\s+detected security violation\s+\(trustzone or non-carveout region\),\s+insecure\s+read\s+will\s+return .*assertion_error"
    -allow_error_string "WARNING\s+:\s+NV_MC_tu\s+\(NV_MC_ASSERT_DEBUG_WARNING\)\s+client.*:\s+detected security violation\s+\(trustzone or non-carveout region\),\s+insecure\s+write\s+will\s+not\s+take\s+effect .*assertion_error"
    -allow_error_string "WARNING : Both PD and WCFLUSH FSM are active"
    -allow_error_string "unable to open melf 0: Failed to open file"
    -allow_error_string "WCFLUSHALL request valid while no flushQ credits avail"
    -allow_error_string "WARNING : CREG flush request valid while no flushQ credits avail"
    -allow_error_string "enabled filldata byte lanes cannot be X"
    -allow_error_string "WARNING : NV_MC_tu.*ASSERT_DEBUG_WARNING.*detected security violation.*"
    -allow_error_string "JSR REDIR SUPP_TH MISMATCH"
    -allow_error_string "stop_after_n_errors"
    -allow_error_string "hard_stop_after_n_errors"
    -allow_error_string "enabled filldata byte lanes cannot be X"
    -allow_error_string "WARNING : NV_MC_tu.*ASSERT_DEBUG_WARNING.*detected security violation.*"
    -allow_error_string "JSR REDIR SUPP_TH MISMATCH"
    -allow_error_string ":E:l2c02roc_req_fill_monitor:check_X_filldata: NCRd or ICRd filldata at byte"
    -allow_error_string ":E:l2c02roc_req_fill_monitor:check_X_filldata: DRAM/MMIO RD fillData X"
    -allow_error_string "Error: \"../../../../../../../../ip/t132/cpu/denver/29274340/ccplex/2.0/stand_sim/ccroc/cd100/../../../dvlib/transactors/cd100/sch/sch_pmc_checker.svh\""
)

DENVER_ARGS0=(
    -rtlarg "+zero_irams"
    -deletepasslogs
    -rtlarg "+uvm_test_top.u_nv_top.ccroc0_0.u_ccroc.u_roc.npg.dpmu.dpmu_checker.enable=0 +*.*bundle_limit=50000000 +*mmu_checker.Enable=0 +reset_vector=0x8fff0000 +enable_axi_pc=1 +show_pc=0 +show_regs=0 +seed=1 +show_disass=1 +show_xbar=1"
    -rtlarg +sknobs_file=/home/ip/t132/cpu/denver/tests/sknobs/t132_sys_sim_rtapi_nochecks.sknobs
    -rtapi_denver
    -denver_mts
    -rtlarg "+asserts_are_warnings +unit_asserts_are_warnings +full_chip_asserts_are_warnings"
    -rtlarg " +asserts_are_warnings +unit_asserts_are_warnings +full_chip_asserts_are_warnings"
    -post_script $(depth)/bin/soc_x_chkr.pl
)

#eko "${DENVER_ARGS[@]}"


while (($# > 0))
do
  case "${1}" in
      -n|--pretend|--dry-run) EZEC=echo; no_run_p=t; no_csh_check_p=t;;
      -v|--verbose) set -x;;
      -q|--quiet) set +x;;
      -x) set -x;;
      -k|--eko) EZEC=eko; no_run_p=t; no_csh_check_p=t;;
      -s|--start|--startrecord|--start-record) shift; startrecord="${1}";;
      -w|--wave|--waves|-wave|-waves) dump_waves_opt=-waves;;
      -P|--proj|--project|--chip) shift; project="${1}"; echo_id project;;
      --prog|--program|--test|--test-name) shift; testname="${1}";;
      -p|--print|--printouts) printout_flag_p=-p;;
      -a|--args|--prog-args|--program-args) shift; test_args="${1}";;
      -d|--denver) run_cmd="${DENVER_RUN_CMD}"; run_cmd_args=("${DENVER_ARGS[@]}");;
      --no-elves|--no-elf) no_elves_p=t;;
      --t124) run_cmd="${RUN_CMD}"; run_cmd_args=("${T124_ARGS[@]}"); mode_arg='-mode arm'
              project=t124;;
      -r|--run-cmd-args) shift; run_cmd_args=("${1}");;
      -m|--mode) shift; mode_arg="-mode ${1}";;
      --config|-config) shift; config="${1}";;
      --add-suite) shift; suites+=("${1}");;
      --no-suites) suites=();;
      --no-errors|--no-error|--no-allow|--no-allow-errors) no_allow_errors_p=t;;
      --no-rtl|--si|--silicon) no_allow_errors_p=t; no_elves_p=t;;
      --suites) shift; suites=(${1});;
      --no-csh-check|--no-csh|--bash-ok|--any-shell|--any-sh) no_csh_check_p=t;;
      --dot-sh|--.sh) no_csh_check_p=t;;
#       --rtprint|-rtprint) rtprint_opt="-rtprint";;
#       --ddd|-ddd) ddd_opt="-ddd";;
#       --debug|-debug) debug_opt="-debug";;
#       --debug-level|-debug-level) shift; debug_level_opt="-debug_level ${1}";;
      -*) echo 1>&2 "Unsupported option-looking arg>${1}<";
          break;;
       *) break;;
  esac
  shift
done

vtruep "${no_allow_errors_p}" && {
    ALLOW_ERROR_ARGS=()
}

vtruep "${no_elves_p}" && {
    elves=
}

DENVER_ARGS=(
    "${ALLOW_ERROR_ARGS[@]}"
    "${DENVER_ARGS0[@]}"
)

#eko "${DENVER_ARGS[@]}"

# :${x=y} don't work with arrays?
vunsetp "${run_cmd_args}" && run_cmd_args=("${DENVER_ARGS[@]}")

#eko "${run_cmd_args[@]}"

#: ${run_cmd_args=-}
#if [ "${run_cmd_args}" = '-' ]
#then
#    run_cmd_args=${DENVER_ARGS}
#fi
#eko "${run_cmd_args[@]}"
: ${run_cmd:=${DENVER_RUN_CMD}}
: ${rtl_log_file_history:=rtl-log-file-history}

echo "Remaining args after option parsing, \$@>$@<"

vtruep "${no_csh_check_p}" || {
    confirmation_response='TRUST ME' csh-p || exit $?
}

if [ -z "${no_run_p-}" ]
then
    run_prefix=
else
    run_prefix="{-}"
fi

abspath()
{
    local path="${1}"
    ( cd $(dirname "${path}"); echo "${PWD}/$(basename ${path})" )
}

echo "Rundir >$rundir<, >$(cd $rundir; pwd)<"

runlog="${PWD}/dp-rtl-tests/runlog"

logdir="${PWD}/dp-rtl-tests/${config}-${timestamp}"
logfile="${logdir}/${testname}.log"
mk_logdir_command="mkdir -p ${logdir}"
if [ -z "${no_run_p}" ]
then
    ${mk_logdir_command} || {
        rc="${?}"
        echo "Cannot create logdir >$logdir<, RC: ${rc}"
        exit "${rc}"
    } 1>&2
else

    echo "${run_prefix}${mk_logdir_command}"
fi

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

{
    echo "${run_prefix}${logfile}"
    echo "${run_prefix}${run_cmd}: $(abspath ${run_cmd})"
}  | tee -a "${rtl_log_file_history}" | tee "${rtl_log_file_history}.latest"

echo "rtl_log_file_history: $(abspath ${rtl_log_file_history})"

if [ -n "${test_args}" ]
then
    test_args=" ${test_args}"
    for suite in "${suites[@]}"
    do
      test_args="${test_args} suite=${suite}"
    done
    {
        echo "${run_prefix}${run_cmd}: $(abspath ${run_cmd})"
    }  | tee -a "${rtl_log_file_history}" | tee -a "${rtl_log_file_history}.latest"
fi

echo "--" >> "${rtl_log_file_history}"

if [ -n "${elves}" ]
then
    elf_load_opt=("-elf_load" "${elves}")
else
    elf_load_opt=()
fi
#use $@ directly     ${rtprint_opt} \
#use $@ directly     ${ddd_opt} \
#use $@ directly     ${debug_opt} \
#use $@ directly     ${debug_level_opt} \
${EZEC} "${run_cmd}" \
    -P "${project}" \
    ${printout_flag_p} \
    ${mode_arg} \
    ${dump_waves_opt} \
    ${startrecord_opt} \
    "${run_cmd_args[@]}" \
    -dir "${logdir}" \
    -o "${logfile}" \
    -noClean \
    -traces "${trace_dir}" \
    "${elf_load_opt[@]}" \
    -mods "-top -cpu_rtl -pitch -zt_count_0 -i ${hdr_file} -o ${logdir}/${testname}.mods -plugin '${testname}${test_args}'" \
    "$@" \
    "${testname}${testext}" \
    -v "${config}"

exit

#e.g. qsub -Is -P t132 -q o_cpu_rel5_16G \
#e.g. $(depth)/bin/denver_system_run  \
#e.g.     -P t132 \
#e.g.     -allow_error_string "ERROR: \(PLL24G_DYN_PRB_ESD\)  An error in SETUP or power is preventing the PLL from starting" \
#e.g.     -allow_error_string "0 demoted errors" \
#e.g.     -allow_error_string "DSIM Warning: DMTRR* applies to both secure and non-secure space; intentional\? failed\:" \
#e.g.     -allow_error_string "Verilog status: assertion\-errors\=0" \
#e.g.     -allow_error_string "WARNING : SCH FDIV state does not match FPS"  \
#e.g.     -allow_error_string "Incorrect configuration for uncore pmc_counter" \
#e.g.     -allow_error_string "failed: file .*tlb_arm\.support" \
#e.g.     -allow_error_string "LS0 RdReq sent to L2 when there are no credits available" \
#e.g.     -allow_error_string "LS1 RdReq sent to L2 when there are no credits available" \
#e.g.     -allow_error_string "WARNING : ATB_ERRM_ATBHS. When ATVALID is asserted, ATVALID de-asserted before ATREADY asserted is not permitted." \
#e.g.     -allow_error_string "WARNING.*csite_datb_pc_checker" \
#e.g.     -allow_error_string "WARNING\s+:\s+NV_MC_tu\s+\(NV_MC_ASSERT_DEBUG_WARNING\)\s+client.*:\s+detected security violation\s+\(trustzone or non-carveout region\),\s+insecure\s+read\s+will\s+return .*assertion_error" \
#e.g.     -allow_error_string "WARNING\s+:\s+NV_MC_tu\s+\(NV_MC_ASSERT_DEBUG_WARNING\)\s+client.*:\s+detected security violation\s+\(trustzone or non-carveout region\),\s+insecure\s+write\s+will\s+not\s+take\s+effect .*assertion_error" \
#e.g.     -rtlarg "+zero_irams" \
#e.g.     -allow_error_string "WARNING : Both PD and WCFLUSH FSM are active" \
#e.g.     -allow_error_string "unable to open melf 0: Failed to open file" \
#e.g.     -allow_error_string "WCFLUSHALL request valid while no flushQ credits avail" \
#e.g.     -allow_error_string "WARNING : CREG flush request valid while no flushQ credits avail" \
#e.g.     -deletepasslogs \
#e.g.     -rtlarg "+uvm_test_top.u_nv_top.ccroc0_0.u_ccroc.u_roc.npg.dpmu.dpmu_checker.enable=0 +*.*bundle_limit=50000000 +*mmu_checker.Enable=0 +reset_vector=0x8fff0000 +enable_axi_pc=1 +show_pc=0 +show_regs=0 +seed=1 +show_disass=1 +show_xbar=1" \
#e.g.     -rtlarg +sknobs_file=/home/ip/t132/cpu/denver/tests/sknobs/t132_sys_sim_rtapi_nochecks.sknobs \
#e.g.     -rtapi_denver \
#e.g.     -denver_mts \
#e.g.     -allow_error_string "enabled filldata byte lanes cannot be X" \
#e.g.     -rtlarg "+asserts_are_warnings +unit_asserts_are_warnings +full_chip_asserts_are_warnings" \
#e.g.     -allow_error_string "WARNING : NV_MC_tu.*ASSERT_DEBUG_WARNING.*detected security violation.*" \
#e.g.     -allow_error_string "JSR REDIR SUPP_TH MISMATCH"  \
#e.g.     -allow_error_string "stop_after_n_errors" \
#e.g.     -allow_error_string "hard_stop_after_n_errors" \
#e.g.     -allow_error_string "enabled filldata byte lanes cannot be X" \
#e.g.     -rtlarg " +asserts_are_warnings +unit_asserts_are_warnings +full_chip_asserts_are_warnings" \
#e.g.     -allow_error_string "WARNING : NV_MC_tu.*ASSERT_DEBUG_WARNING.*detected security violation.*" \
#e.g.     -allow_error_string "JSR REDIR SUPP_TH MISMATCH"  \
#e.g.     -allow_error_string ":E:l2c02roc_req_fill_monitor:check_X_filldata: NCRd or ICRd filldata at byte" \
#e.g.     -allow_error_string ":E:l2c02roc_req_fill_monitor:check_X_filldata: DRAM/MMIO RD fillData X" \
#e.g.     -post_script $(depth)/bin/soc_x_chkr.pl \
#e.g.     -dir /home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/satish \
#e.g.     -o /home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/satish/cpu_surface_write_read.log \
#e.g.     -noClean \
#e.g.     -traces /home/scratch.dpanariti_t124_3/sb4/sb4hw/arch/traces/mobile/traces/gpu_multiengine \
#e.g.     -mods "-top -cpu_rtl -pitch -zt_count_0 -i /home/scratch.dpanariti_t124_3/sb4/sb4hw/arch/traces/mobile/traces/gpu_multiengine/comp_one_tri_redline/test.hdr -o TestDir/cpu_surface_write_read -plugin 'cpu_surface_write_read mapping_mode=reflected default_door no_check_mem_reg series_len=1 num_series=1 test=rtmem-rtmem'" \
#e.g.     cpu_surface_write_read.so \
#e.g.     -v top_peatrans_gpurtl
