#!/bin/bash

# run inc+proc0.sh and capture stderr to an output file

#LOG='/tmp/inc+proc-stderr.out'
#echo "=== `date` ====" >> $LOG
exec inc+proc0.sh "$@" ###2>> $LOG

