#!/bin/sh

# Surprise! We're a shell script fronting for a python program.

export DP_SCRIPT_X_DASH_X_STR=-SCRIPT_X

source script-x
set -u
progname="$(basename $0)"
source eexec
eexec_program=$(EExec_parse "$@")
for op in $eexec_program
do
  $op
  shift
done
unset eexec_program

export util_name=//hw/ap_tlit1/drv/multiengine/scripts/imgview.py

exec me-run-program "$@"
