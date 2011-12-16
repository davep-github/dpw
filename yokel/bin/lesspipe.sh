#!/bin/sh
#set -x
# This is a preprocessor for 'less'.  It is used when this environment
# variable is set:   LESSOPEN="|lesspipe.sh %s"

  case "$1" in
  *.tar) tar tvvf $1 2>/dev/null ;; # View contents of .tar and .tgz files
  *.tgz) tar tzvvf $1 2>/dev/null ;;
  *.tz) tar tzvvf $1 2>/dev/null ;;
  *.tar.gz) tar tzvvf $1 2>/dev/null ;;
  *.tar.Z) tar tzvvf $1 2>/dev/null ;;
  *.tar.z) tar tzvvf $1 2>/dev/null ;;
  *.Z) gzip -dc $1  2>/dev/null ;; # View compressed files correctly
  *.z) gzip -dc $1  2>/dev/null ;;
  *.gz) gzip -dc $1  2>/dev/null ;;
  *.zip) unzip -l $1 2>/dev/null ;;
  *.1|*.2|*.3|*.4|*.5|*.6|*.7|*.8|*.9|*.n|*.man) FILE=`file $1` ; # groff src
    FILE=`echo $FILE | cut -d ' ' -f 2`
    case  "$FILE" in
        *roff*) groff -s -p -t -e -Tascii -mandoc $1;;
    esac
    ;;
#  *) FILE=`file -L $1` ; # Check to see if binary, if so -- view with 'strings'
#    FILE1=`echo $FILE | cut -d ' ' -f 2`
#    FILE2=`echo $FILE | cut -d ' ' -f 3`
#    if [ "$FILE1" = "Linux/i386" -o "$FILE2" = "Linux/i386" \
#         -o "$FILE1" = "ELF" -o "$FILE2" = "ELF" ]; then
#      strings $1
#    fi ;;
  esac
