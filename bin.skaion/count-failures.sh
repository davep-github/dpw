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
# trap 'on_exit' 0

on_error()
{
    local rc="${1-}"; shift

    echo "on_exit: rc: $rc; ${trap_exit_msg}"
    trap '' 0
}
# trap 'on_error' ERR

sig_exit ()
{
    {
        local sig_num=$1; shift
        echo
        echo "sig_exit, sig_num: $sig_num"
        dump_bad_nodes $bad_nodes
        exit 1
    } 1>&2
}

# for sig in 2 3 4 5 6 7 8 15
# do
#     trap "sig_exit $sig" $sig
# done

#
# template ends.
########################################################################

n="${1}"
shift

percentum()
{
    local num="${1}"; shift
    local den="${1}"; shift

    echo "$(( (num * 100) / den ))"
}

num_lines()
{
    local file="${1}"
    shift
    wc -l "${file}"
}

just_num_lines()
{
    local file="${1}"
    shift
    num_lines "${file}" | awk '{print $1}'
}

failure_summary()
{
    local num_failures="${1}"; shift
    local num_runs="${1}"; shift

    echo "failures $(percentum ${num_failures} ${num_runs})% [${num_failures} of ${num_runs} runs]"
}

base_stamp=$(dp-std-timestamp)
: ${results_dir:="cf.results.d/${base_stamp}.d"}
echo "Results dir: ${results_dir}"
mkdir -p "${results_dir}"

num_runs_with_pmu_failures=0
num_runs_with_rtt_failures=0
rm -f cf.fail*.total
fail_total_file="../fail.total"
fail_pmu_total_file="../fail_pmu.total"
fail_rtt_total_file="../fail_rtt.total"
for i in $(pyrange "${n}")
do
  run_dir="${results_dir}/${i}"
  echo "=== Iteration: ${i}: run dir: ${run_dir} ==="
  mkdir -p "${run_dir}"
  EExec "$@" --no-yopp 2 >| "${run_dir}/cf.err" 1 >| "${run_dir}/cf.out" || {
      echo "Failed: $@"
      continue
  }
  pushd "${run_dir}" >/dev/null 2>&1
  fgrep FAIL "cf.out"  >| cf.fail.out
  cat cf.fail.out >> "${fail_total_file}"

  fgrep PMU cf.fail.out >| cf.fail.pmu
  cat cf.fail.pmu >> "${fail_pmu_total_file}"
  [ -s cf.fail.pmu ] && {
      ((++num_runs_with_pmu_failures))
      echo "Num PMU errors this run: $(just_num_lines cf.fail.pmu)"
  }
  echo "Total errors so far: $(just_num_lines ${fail_pmu_total_file})"
  echo "PMU $(failure_summary ${num_runs_with_pmu_failures} $((i + 1)))"
  echo '--'

  fgrep RTT cf.fail.out >| cf.fail.rtt
  cat cf.fail.rtt >> "${fail_rtt_total_file}"
  [ -s cf.fail.rtt ] && {
      ((++num_runs_with_rtt_failures))
      echo "Num RTT errors this run: $(just_num_lines cf.fail.rtt)"
  }
  echo "Total errors so far: $(just_num_lines ${fail_rtt_total_file})"
  echo "RTT $(failure_summary ${num_runs_with_rtt_failures} $((i + 1)))"
  echo '--'

  # Due to a wonderful design decision, values will not persist once the loop
  # exists. Because of that we must do this in the loop, but we only do it on
  # the last iteration.
  if ((i == (n - 1)))
  then
      echo "===== Final Results ====="
      if ((num_runs_with_pmu_failures > 0))
      then
          echo "Final: PMU $(failure_summary ${num_runs_with_pmu_failures} ${n})"
          echo "  Total failures: $(just_num_lines ${fail_pmu_total_file})"
      fi
      if ((num_runs_with_rtt_failures > 0))
      then
          echo "Final: RTT $(failure_summary ${num_runs_with_rtt_failures} ${n})"
          echo "  Total failures: $(just_num_lines ${fail_rtt_total_file})"
      fi
  fi
  popd >/dev/null 2>&1

done 2>&1 | tee "${results_dir}/cf-all.log"

echo "results_dir>${results_dir}<"

