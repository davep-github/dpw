#!/bin/bash

source script-x
source eexec
set -u
progname="$(basename $0)"

: ${verbose_p=}

[ -n "$verbose_p" ] && EExecVerbose

EExec_verbose_msg "May see this because EExecVerbose was called conditionally on
verbose_p>$verbose_p<"

EExecVerbose

EExec_verbose_msg "Will see this because EExecVerbose was called unconditionally."

EExecVerbose ""
EExec -k false keep-going
EExec -k --one-ok false 1 is no error
EExec -k --ok-error: 2 false 1 is not two
EExec false just false.
echo "? is $?"
EExec_verbose_msg Were they ok?
