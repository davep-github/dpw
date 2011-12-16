#!/bin/sh

LOG=/tmp/cmd-logger.log
eko "$@" >> $LOG
#cat | tee -a $LOG | hd
gmake "$@"
