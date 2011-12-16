#!/bin/sh

source script-x
source eexec

[ -z "$*" ] && {
  echo 1>&2 "I need something with which to identify the current version."
  exit 1
}

VERSION_ID="$1"
: ${XEM_PATCH_BASE_DIR:=$HOME/patches/xemacs}
: ${XEM_DUMPED_PATCHES:=$XEM_PATCH_BASE_DIR/dumped}
: ${XEM_SRC_PATCHES:=$XEM_PATCH_BASE_DIR/src}
: ${XEM_ORIGINALS_DIR:=../dp-patches-Originals}
: ${XEM_LISP_ORIGINALS_DIR:=$XEM_ORIGINALS_DIR/lisp}
: ${XEM_SRC_ORIGINALS_DIR:=$XEM_ORIGINALS_DIR/src}


echo "Looking for >$VERSION_ID< in >$PWD<"
case "$PWD" in
  *$VERSION_ID*) ;;
  *) echo 1>&2 "You don't seem to be in $VERSION_ID'S dir."; exit 2;;
esac

# Patch lisp first.
# We should be some VERSION_ID'y lisp place.
case "$PWD" in
  *$VERSION_ID*/lisp) ;;
  *) echo 1>&2 "You don't seem to be in $VERSION_ID's lisp dir."; exit 3;;
esac

# -p lets it work if the dir exists but doesn't toss any other error checking.
EExec mkdir -p $XEM_LISP_ORIGINALS_DIR
EExec mkdir -p $XEM_SRC_ORIGINALS_DIR

#
# OK, we're in a lispy place, let's patch some lispy files.
#

#
# Count on my file naming convention, or use patch file info:
# --- buff-menu.el.orig	2005-12-23 06:40:33.000000000 -0500
# +++ buff-menu.el	2006-02-26 15:02:36.000000000 -0500
# `-- first char on line.

patch_em()
{
  local originals_dir="$1"
  shift
  local patch_files=("$@")
  for patch_file in "${patch_files[@]}"; do
    patch_file_base=$(basename $patch_file)
    fname=$(head -n2 $patch_file | tail -n1 | sed -rn 's/(\+\+\+ )([^ \t]+)(.*)$/\2/p')
    fname=$(basename $fname)
    echo "Attempting to patch \`$fname' with \`$patch_file'"
    orig_file_name=$originals_dir/$fname
    echo "Backing up \`$fname' to \`$orig_file_name'"
    [ -e "$orig_file_name" ] && {
      echo "Backup copy of original file \`$orig_file_name' already exists."
      read -e -p "Assume we're already patched and continue(Y/n)? "
      case "$REPLY" in
        [nN]) EXIT 2;;
      esac
    } 1>&2

    [ -e "$orig_file_name" ] || {
      EExec cp $fname $orig_file_name
      yes n | EExec patch < $patch_file
      # Just in case the patch is now a few lines off.  Files names will be
      # different, so come code will be needed to diff the diffs w/o
      # getting thrown off by the name diffs.
      diff -u $orig_file_name $fname > $originals_dir/AM-I-DIFFERENT-$patch_file_base
    }
  done
}

# Patch lisps
patch_em ${XEM_LISP_ORIGINALS_DIR} ${XEM_DUMPED_PATCHES}/*${VERSION_ID}*.diff

# srcs.
cd ../src
patch_em ${XEM_SRC_ORIGINALS_DIR} ${XEM_SRC_PATCHES}/*${VERSION_ID}*/*.diff
