#!/bin/sh

source script-x
set -u
progname="$(basename $0)"
source eexec
eexec_program=$(EExec_parse "$@")
for op in $eexec_program
do
  $op
  shift
done
unset eexec_program

: ${FILES_TO_NUKE="
CMakeCache.txt 
CMakeFiles/ 
cmake_install.cmake 
install_manifest.txt 
Makefile 
*.so"}

EExec rm -rf ${FILES_TO_NUKE}

