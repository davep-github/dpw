#!/bin/bash
# $Id: get-amarok-cvs.sh,v 1.2 2005/01/31 09:20:05 davep Exp $
# Originally from the Amarok website.
# get-amarok-cvs.sh 
# http://amarok.sf.net/download/scripts/get-amarok-cvs.sh
# This script installs the current development version of amarok on your pc.
set -x

OLDDIR=$(pwd)
: ${install:=}
: ${reuse:=}

TMPDIR=amarok-*.tmp.d
if [ -d "$TEMDIR" -a -n "$reuse" ]
then
    :                           # TMPDIR=amarok-*.tmp.d
else
  TMPDIR="/usr/bree/src/amarok/amarok-$(date +%Y%j%H%M%S).tmp.d"
  mkdir $TMPDIR
fi

cd $TMPDIR
export CVSROOT=":pserver:anonymous@bluemchen.kde.org:/home/kde"
cvs -z4 co kde-common/admin
cvs -z4 co -l kdeextragear-1
cvs -z4 co kdeextragear-1/amarok
cd kdeextragear-1
ln -s ../kde-common/admin
WANT_AUTOCONF="2.5" make -f Makefile.cvs
CFLAGS='-g' CXXFLAGS='-g' ./configure --prefix=$(kde-config --prefix) \
 --with-pic --enable-mysql

if [ "$?" != '0' ]
then
  echo 1>&2 configure failed.
  exit 1
fi

if [ -n "$ASK_TO_MAKE" ]
then
  echo -n 'Proceed with make (y/N)? '
  read x
  case "$x" in
    y|Y|1|[Yy][Ee][Ss]) ;;
    *) echo 'Not making.'
       exit 0;;
  esac
fi

make
rc=$?

if [ "$rc" = "0" ]; then 
  clear;
  echo "Compilation successful.";
  #echo "Please enter your root password to install amaroK.";
  [ -z "$install" ] && {
    echo
    echo
    echo
    echo
    echo -n 'Install (y/N)? '
    read install
}
case "$install" in
  y|Y|1|[Yy][Ee][Ss]) ;;
  *) echo 'Not installing.'
     exit 0;;
esac

sudo make install
rc=$?
fi

exit $rc
