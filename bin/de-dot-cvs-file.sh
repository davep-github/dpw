#!/bin/bash

. eexec

#EExecShowOnly=y

for file in $*
do
  nodot=`echo $file | sed 's/^\.//'`
  # echo $nodot
  EExec mv $file $nodot
  EExec cvs rm $file
  EExec cvs add $nodot
done

