#!/bin/bash

source script-x

# Place after parsing args.
# This gives command-line, env var, default behavior.
# kwa_ keyword argument.
: ${create_client_p:=${kwa_ccp="default"}}


#############################################################################
# Load as library or run as a script.
# Analogous to Python's __main__ check.
# running_as_script(dp) runs:
# name_is___main__ ()
# {
#     [ -z "${DP_IMPORTING_P-}" ]
# }
# Where $DP_IMPORTING_P is normally "" or null and must be set to force the
# script to act as a library.

if dp_runme #  >> older, defecating it. >> running_as_script
then
    XXX "$@"
    exit                        # With XXX's code.
else
    # "library" load.
    exit 0
fi

exit 99 <<<<< debug early exit. dp_decode_cmd_status(dp) decodes it.
exit 88 <<<<< reminder exit. dp_decode_cmd_status(dp) decodes it.
exit 123
