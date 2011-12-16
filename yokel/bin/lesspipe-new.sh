#!/usr/bin/env bash
#!/bin/ksh
#!/bin/zsh -y
#===============================================================================
# lesspipe.sh, a preprocessor for less (version 1.22)
#
# Usage:   lesspipe.sh is called when the environment variable LESSOPEN is set:
#	   LESSOPEN="|lesspipe.sh %s"; export LESSOPEN	(sh like shells)
#	   setenv LESSOPEN "|lesspipe.sh %s"		(csh, tcsh)
#	   Use the fully qualified path if lesspipe.sh is not in the search path
#	   View files in multifile archives:
#				less archive_file:contained_file
#	   This can be used to extract single files from a multifile archive:
#				less archive_file:contained_file>extracted_file
#          Even a file in a multifile archive that itself is contained in yet
#          another archive can be viewed this way:
#				less super_archive:archive_file:contained_file
#	   Display the last file in the file1:..:fileN chain in raw format:
#	   Suppress input filtering:	less file1:..:fileN:   (append a colon)
#	   Suppress decompression:	less file1:..:fileN::  (append 2 colons)
# Required programs:
#	   bash (at least version 2.04 or ksh from vendor or zsh)
#	   (choose the appropriate line as the first line in the script)
#	   file (a version that recognizes the supported formats)
#	   ls, rm, cat, cut and further programs for special formats
# Supported formats:
#	   gzip, compress, bzip2, zip, tar, nroff(mandoc), ar library, pdf,
#	   shared library, executable, directory, RPM, Microsoft Word, Debian
#	   files and Filesystems on removable media via /dev/xxx
#	   (see also separate file README)
#
# License: GPL (see file LICENSE)
#
# History: see separate file ChangeLog
# 	   http://www.desy.de/zeuthen/~friebel/unix/lesspipe.html
#
# Author:  Wolfgang Friebel DESY Zeuthen (Wolfgang.Friebel@desy.de)
#===============================================================================
tarcmd=gtar
if [[ `tar --version 2>&1` = *GNU* ]]; then
  tarcmd=tar
fi
filecmd='/usr/bin/file -L -s';
sep=:						# file name separator
altsep==					# alternate separator character
if [[ -f "$1" && "$1" = *$sep* || "$1" = *$altsep ]]; then
  sep=$altsep
fi
tmp=/tmp/.lesspipe.$$				# temp file name
trap 'rm -f $tmp $tmp.fin $tmp. $tmp.. $tmp.1' 0
trap PIPE

rarcmd=rar

show () {
  file1=${1%%$sep*}
  rest1=${1#$file1}
  rest11=${rest1#$sep}
  file2=${rest11%%$sep*}
  rest2=${rest11#$file2}
  rest11=$rest1
  if [[ $# = 1 ]]; then
    type=`$filecmd "$file1" | cut -d : -f 2-`
    get_cmd "$type" "$file1" $rest1
    if [[ "$cmd" != "" ]]; then
      show "-$rest1" "$cmd"
    else
      isfinal "$type" "$file1" $rest11
    fi
  elif [[ $# = 2 ]]; then
    type=`$2 | $filecmd - | cut -d : -f 2-`
    get_cmd "$type" "$file1" $rest1
    if [[ "$cmd" != "" ]]; then
      show "-$rest1" "$2" "$cmd"
    else
      $2 | isfinal "$type" - $rest11
    fi
  elif [[ $# = 3 ]]; then
    type=`$2 | $3 | $filecmd - | cut -d : -f 2-`
    get_cmd "$type" "$file1" $rest1
    if [[ "$cmd" != "" ]]; then
      show "-$rest1" "$2" "$3" "$cmd"
    else
      $2 | $3 | isfinal "$type" - $rest11
    fi
  elif [[ $# = 4 ]]; then
    type=`$2 | $3 | $4 | $filecmd - | cut -d : -f 2-`
    get_cmd "$type" "$file1" $rest1
    if [[ "$cmd" != "" ]]; then
      show "-$rest1" "$2" "$3" "$4" "$cmd"
    else
      $2 | $3 | $4 | isfinal "$type" - $rest11
    fi
  elif [[ $# = 5 ]]; then
    type=`$2 | $3 | $4 | $5 | $filecmd - | cut -d : -f 2-`
    get_cmd "$type" "$file1" $rest1
    if [[ "$cmd" != "" ]]; then
      show "-$rest1" "$2" "$3" "$4" "$5" "$cmd"
    else
      $2 | $3 | $4 | $5 | isfinal "$type" - $rest11
    fi
  elif [[ $# = 6 ]]; then
    type=`$2 | $3 | $4 | $5 | $6 | $filecmd - | cut -d : -f 2-`
    get_cmd "$type" "$file1" $rest1
    if [[ "$cmd" != "" ]]; then
      echo "$0: Too many levels of encapsulation"
    else
      $2 | $3 | $4 | $5 | $6 | isfinal "$type" - $rest11
    fi
  fi
}

get_cmd () {
  cmd=
  if [[ "$2" = /*\ * ]]; then
    ln -s "$2" $tmp..
    set "$1" $tmp..
  elif [[ "$2" = *\ * ]]; then
    ln -s $PWD/"$2" $tmp..
    set "$1" $tmp..
  fi

  if [[ "$1" = *bzip* || "$1" = *compress[\'e]d\ * ]]; then
    if [[ "$3" = $sep$sep ]]; then
      return
    elif [[ "$1" = *bzip* ]]; then
      cmd="bzip2 -c -d $2"
    else
      cmd="gzip -c -d $2"
    fi
    return
  fi
    
  rest1=$rest2
  if [[ "$file2" != "" ]]; then
    if [[ "$1" = *tar* ]]; then
      cmd="$tarcmd Oxf $2 $file2"
    elif [[ "$1" = *RAR* ]]; then
      cmd="$rarcmd p -inul $2 $file2"
    elif [[ "$1" = *RPM* ]]; then
      cmd="isrpm $2 $file2"
    elif [[ "$1" = *Zip* ]]; then
      cmd="iszip $2 $file2"
    elif [[ "$1" = *\ ar\ archive* ]]; then
      cmd="isar $2 $file2"
    elif [[ "$1" = *x86\ boot\ sector* ]]; then
      cmd="isfloppy $2 $file2"
    fi
  fi
}

isdeb() {
  if [[ "$1" = - ]]; then
    rm -f $tmp
    cat > $tmp
    set $tmp "$2"
  fi
  dpkg-deb --info $1 >| /tmp/debi
  echo '========= contents ========='
  dpkg-deb --contents $1 >| /tmp/debc
}

iszip () {
  if [[ "$1" = - ]]; then
    rm -f $tmp
    cat > $tmp
    set $tmp "$2"
  fi
  unzip -avp "$1" "$2"
}

isar () {
  if [[ "$1" = - ]]; then
    rm -f $tmp
    cat > $tmp
    set $tmp "$2"
  fi
  ar p "$1" "$2"
}

isrpm () {
  if [[ "$1" = - ]]; then
    rm -f $tmp
    cat > $tmp
    set $tmp "$2"
  fi
  echo $tmp.1 > $tmp.
# GNU cpio has an undocumented but most useful --rename-batch-file switch
  rm -f $tmp.1
  rpm2cpio $1|cpio -i --quiet --rename-batch-file $tmp. ${2##/}
  cat $tmp.1
}


isfloppy () {
# get the device to drive mapping
  mtoolstest |
  while read i1 i2
  do
    if [[ "$i1" = *$1* ]]; then
      if [[ "$2" = "" ]]; then
	mdir $drive
      else
	mtype $drive$2
      fi
      return
    elif [[ "$i1" = drive ]]; then
      drive=$i2
    fi
  done
}

isfinal() {

  if [[ "$3" = $sep || "$3" = $sep$sep ]]; then
    cat $2
    return
  elif [[ "$2" = - ]]; then
    case "$1" in 
    *RPM*|*\ ar\ archive*|*shared*|*Zip*)
      cat > $tmp.fin
      set "$1" $tmp.fin
    esac
  fi
  if [[ "$1" = *No\ such* ]]; then
    return
  fi
  if [[ "$1" = *Debian\ binary\ package* ]]; then
    echo "==> This is a deb package"
    dpkg-deb --info "$2"
    echo "=================================== contents =================================="
    dpkg-deb --contents "$2"
  elif [[ "$1" = *directory* ]]; then
    echo "==> This is a directory, showing the output of ls -lAL"
    ls -lAL "$2"
  elif [[ "$1" = *tar* ]]; then
    echo "==> use tar_file${sep}contained_file to view a file in the archive"
    $tarcmd tvf "$2"
  elif [[ "$1" = *RPM* ]]; then
    echo "==> use RPM_file${sep}contained_file to view a file in the RPM"
    rpm -p "$2" -qiv
    rpm2cpio $2|cpio -i -tv --quiet
  elif [[ "$1" = *roff* ]]; then
    echo "==> append $sep to filename to view the nroff source"
    groff -s -p -t -e -Tascii -mandoc ${2#-}
  elif [[ "$1" = *text\ executable* ]]; then
    if [[ "$2" = - ]]; then
      cat
    fi
  elif [[ "$1" = *executable* ]]; then
    echo "==> append $sep to filename to view the binary file"
    strings ${2#-}
  elif [[ "$1" = *\ ar\ archive* ]]; then
    echo "==> use library${sep}contained_file to view a file in the archive"
    ar vt "$2"
  elif [[ "$1" = *shared* ]]; then
    echo "==> This is a dynamic library, showing the output of nm"
    nm "$2"
  elif [[ "$1" = *Zip* ]]; then
    echo "==> use zip_file${sep}contained_file to view a file in the archive"
    unzip -lv "$2"
  elif [[ "$1" = *x86\ boot\ sector* ]]; then
    echo "==> use $2${sep}contained_file to view a file on the floppy"
    isfloppy $2
  elif [[ "$1" = *HTML* ]]; then
    if [[ `ps -p $PPID` = *\ less\ * ]]; then
#     browser="w3m -X -T text/html"
      browser=lynx
      echo "==> append $sep to filename to view the HTML source"
      $browser -dump "$2"
    fi
  elif [[ "$1" = *Microsoft\ Word* || "$1" = *Microsoft\ Office* ]]; then
    antiword "$2"
##ifdef convert,aview
# very experimental attempt to display images using ASCII art (do not use)
#  elif [[ "$1" = *image\ data*  || "$1" = *image\ text* || "$1" = *JPEG\ file*  || "$1" = *JPG\ file* ]]; then
#    convert "$2" /tmp/.lesspipe.pnm
#    echo 'q' | aview -kbddriver stdin -driver stdout -inverse -eight -nodim -nobold -noreverse -noboldfont /tmp/.lesspipe.pnm 2> /dev/null
#    rm  /tmp/.lesspipe.pnm
##endif
  elif [[ "$1" = *RAR* ]]; then
    echo "==> use rarchive${sep}contained_file to view a file in the archive"
    $rarcmd l "$2"
  elif [[ "$2" = - ]]; then
    cat
  fi
}

# calling show with arg1 arg2 ... is equivalent to calling with arg1:arg2:...
IFS=$sep a="$*"
IFS=' '
show "$a"
