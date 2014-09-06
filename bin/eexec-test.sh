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

