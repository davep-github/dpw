#!/bin/sh

fd=${1:=5}

# Run like this:
# $ ./fds.sh ${fd}>&1
# or
# $ ./fds.sh ${fd}>${fd}.log

# Find out if FD x is valid:
# { echo hi 1>& ${fd}; } 2>/dev/null; echo "RC: $?"

echo hello 1>&${fd}

