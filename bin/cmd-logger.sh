#!/bin/bash

progname=$(basename=$0)
:${LOG:=/home/davep/log}
LOGDIR="$LOG/cmd-wrapping-logger"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/$progname.out"
{
  date
  #echo '0'
  eko "$@"
  #cat | tee -a $LOG | hd
  # while read p
  # do
  #     echo "p>$p<" >> $LOG
  #     echo '==='
  #     echo $p # | "$@"
  # done
  #read p
  #echo "p>$p<" >> $LOG
  #cat | tee -a $LOG | "$@"
  
  read p
  echo "p>$p<" >> $LOG
  echo $p | "$@"
  echo 'done ####################################' >> $LOG
} 
