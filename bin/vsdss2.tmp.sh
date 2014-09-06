#!/bin/bash

. script-x

trap "echo Caught SIGINT, exiting.; exit 0" SIGINT

. $HOME/etc/kfdsrc
. eexec
LOG_FILE="$DP_KFDS_SYSDIR/crash.log"

EExec cd "$DP_KFDS_SYSDIR"

restart="$DP_RESTART_COMMAND $DP_RESTART_COMMAND_ARGS"
echo "Restart command: exec $restart"

server_args=${DP_KFDS_STARTING_MAP}${DP_KFDS_STARTING_ARGS}${DP_KFDS_EXTRA_ARGS}
echo "ucc-bin server ${server_args}"
start_time=$(date)
sudo nice --adjustment=-19 su davep ./ucc-bin server ${server_args}

echo "Session: $start_time - $(date): Crashed (again), rc: $?" >> $LOG_FILE

# Lupus so our players do not become sad.
exec $restart

echo "WFT?!?!? exec $restart failed: $?" >> $LOG_FILE
exit 66
