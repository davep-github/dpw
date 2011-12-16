#!/bin/bash
argList=$*
for arg in $argList
do
	oldIFS=$IFS
	IFS=":"
	for pathEl in $PATH
	do
		targ="$pathEl/$arg"
#		echo checking'>'$targ'<'
#		ls -l $targ
		if [ -x $targ ]
		then
			echo "$targ"
		fi
	done

	IFS=$oldIFS
done
	
