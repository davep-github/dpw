#!/bin/bash

source script-x

# Place after parsing args.
# This gives command-line, env var, default behavior.
# kwa_ keyword argument.
: ${create_client_p:=${kwa_ccp="default"}}


#############################################################################
# Load as library or run as a script.
# Analogous to Python's __main__ check.

if running_as_script
then
    XXX "$@"
    exit                        # With XXX's code.
else
    # "library" load.
    exit 0
fi

exit 123
