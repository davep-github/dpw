#   bash_completion - some programmable completion functions for bash 2.05b
#
#   $Id: bash_completion,v 1.1 2004/07/11 17:56:56 davep Exp $
#
#   Copyright (C) Ian Macdonald <ian@caliban.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your option)
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#   The latest version of this software can be obtained here:
#
#   http://www.caliban.org/bash/index.shtml#completion
#
#   RELEASE: 20040331

[ -n "${DEBUG:-}" ] && set -v || set +v

# Alter the following to reflect the location of this file
#
if [ -n "${FUNCNAME:-}" ]; then
	# we're being sourced from within a function, so we can't use
	# 'declare', as this will create local variables within a function
	BASH_COMPLETION=${BASH_COMPLETION:-/etc/bash_completion} 2>/dev/null
	BASH_COMPLETION_DIR=${BASH_COMPLETION_DIR:=/etc/bash_completion.d} \
	  2>/dev/null
else
	declare -r BASH_COMPLETION=${BASH_COMPLETION:-/etc/bash_completion} \
	  2>/dev/null
	declare -r \
	  BASH_COMPLETION_DIR=${BASH_COMPLETION_DIR:=/etc/bash_completion.d} \
	  2>/dev/null
fi

# Set a couple of useful vars
#
UNAME=$( uname -s )
# strip OS type and version under Cygwin (e.g. CYGWIN_NT-5.1 => Cygwin)
UNAME=${UNAME/CYGWIN_*/Cygwin}
RELEASE=$( uname -r )

# features supported by bash 2.05 and higher
if [ ${BASH_VERSINFO[0]} -eq 2 ] && [[ ${BASH_VERSINFO[1]} > 04 ]] ||
   [ ${BASH_VERSINFO[0]} -gt 2 ]; then
	declare -r bash205=$BASH_VERSION 2>/dev/null
	default="-o default"
	dirnames="-o dirnames"
	filenames="-o filenames"
fi
# features supported by bash 2.05b and higher
if [ ${BASH_VERSINFO[0]} -eq 2 ] && [[ ${BASH_VERSINFO[1]} = "05b" ]] ||
   [ ${BASH_VERSINFO[0]} -gt 2 ]; then
	declare -r bash205b=$BASH_VERSION 2>/dev/null
	nospace="-o nospace"
fi
# features supported by bash 3.0 and higher
if [ ${BASH_VERSINFO[0]} -gt 2 ]; then
	declare -r bash3=$BASH_VERSION 2>/dev/null
	bashdefault="-o bashdefault"
	plusdirs="-o plusdirs"
fi

# Turn on extended globbing and programmable completion
shopt -s extglob progcomp

# A lot of the following one-liners were taken directly from the
# completion examples provided with the bash 2.04 source distribution

# Make directory commands see only directories
complete -d pushd

# The following section lists completions that are redefined later
# Do NOT break these over multiple lines.
#
# START exclude -- do NOT remove this line
complete -f -X '!*.?(t)bz2' bunzip2 bzcat bzcmp bzdiff bzegrep bzfgrep bzgrep
complete -f -X '!*.@(zip|ZIP|jar|JAR|exe|EXE|pk3|war|wsz|ear|zargo|xpi)' unzip zipinfo
complete -f -X '*.Z' compress znew
complete -f -X '!*.@(Z|gz|tgz|Gz|dz)' gunzip zcmp zdiff zcat zegrep zfgrep zgrep zless zmore
complete -f -X '!*.Z' uncompress
complete -f -X '!*.@(gif|jp?(e)g|tif?(f)|pn[gm]|p[bgp]m|bmp|xpm|ico|xwd|tga|pcx|GIF|JP?(E)G|TIF?(F)|PN[GM]|P[BGP]M|BMP|XPM|ICO|XWD|TGA|PCX)' display
complete -f -X '!*.@(gif|jp?(e)g|tif?(f)|png|p[bgp]m|bmp|x[bp]m|rle|rgb|pcx|fits|pm|GIF|JPG|JP?(E)G|TIF?(F)|PNG|P[BGP]M|BMP|X[BP]M|RLE|RGB|PCX|FITS|PM)' xv qiv
complete -f -X '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv
complete -f -X '!*.@(dvi|DVI)?(.@(gz|Z|bz2))' xdvi
complete -f -X '!*.@(dvi|DVI)' dvips dviselect dvitype
complete -f -X '!*.@(pdf|PDF)' acroread gpdf xpdf
complete -f -X '!*.texi*' makeinfo texi2html
complete -f -X '!*.@(?(la)tex|?(LA)TEX|texi|TEXI|dtx|DTX|ins|INS)' tex latex slitex jadetex pdfjadetex pdftex pdflatex texi2dvi
complete -f -X '!*.@(mp3|MP3|m3u)' mpg123 mpg321
complete -f -X '!*.@(mp?(e)g|MP?(E)G|wma|avi|AVI|asf|vob|VOB|bin|dat|vcd|ps|pes|fli|viv|rm|ram|yuv|mov|MOV|qt|QT|wmv|mp3|MP3|ogg|OGG|ogm|OGM|mp4|MP4|wav|WAV|asx|ASX)' xine
complete -f -X '!*.@(avi|asf|wmv)' aviplay
complete -f -X '!*.@(rm|ram|smi?(l))' realplay
complete -f -X '!*.@(mpg|mpeg|avi|mov|qt)' xanim
complete -f -X '!*.@(ogg|OGG|m3u|flac|spx)' ogg123
complete -f -X '!*.@(mp3|MP3|ogg|OGG|pls|m3u)' gqmpeg freeamp
complete -f -X '!*.@(mp[23]|MP[23]|ogg|OGG|wav|WAV|pls|m3u|xm|mod|s[3t]m|it|mtm|ult|flac)' xmms
complete -f -X '!*.fig' xfig
complete -f -X '!*.@(mid?(i))' timidity playmidi
complete -f -X '*.@(o|so|so.!(conf)|a|tar?(.@(gz|bz2))|tgz|tbz2|rpm|zip|ZIP|gif|GIF|jp?(e)g|JP?(E)G|mp3|MP3|mp?(e)g|MPG|avi|AVI|asf|ASF|ogg|OGG|class|CLASS)' vi vim gvim rvim view rview rgvim rgview gview emacs
complete -f -X '!*.@(exe|EXE|com|COM|scr|SCR)' wine
complete -f -X '!*.@(zip|ZIP|z|Z|gz|GZ|tgz|TGZ)' bzme
complete -f -X '!*.@(?([xX]|[sS])[hH][tT][mM]?([lL]))' netscape mozilla lynx opera w3m galeon curl dillo elinks amaya
complete -f -X '!*.@(sxw|stw|sxg)' oowriter
complete -f -X '!*.@(sxi|sti)' ooimpress
complete -f -X '!*.@(sxc|stc)' oocalc
complete -f -X '!*.@(sxd|std)' oodraw
complete -f -X '!*.@(sxm)' oomath
# FINISH exclude -- do not remove this line

# start of section containing compspecs that can be handled within bash

# user commands see only users
complete -u su usermod userdel passwd chage write chfn groups slay w

# group commands see only groups
[ -n "$bash205" ] && complete -g groupmod groupdel newgrp 2>/dev/null

# bg completes with stopped jobs
complete -A stopped -P '%' bg

# other job commands
complete -j -P '%' fg jobs disown

# readonly and unset complete with shell variables
complete -v readonly unset

# set completes with set options
complete -A setopt set

# shopt completes with shopt options
complete -A shopt shopt

# helptopics
complete -A helptopic help

# unalias completes with aliases
complete -a unalias

# bind completes with readline bindings (make this more intelligent)
complete -A binding bind

# type and which complete on commands
complete -c command type which

# start of section containing completion functions called by other functions

# This function checks whether we have a given programs on the system.
# No need for bulky functions in memory if we don't.
#
have()
{
	unset -v have
	PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin type $1 &>/dev/null &&
		have="yes"
}

# use GNU sed if we have it, since its extensions are still used in our code
#
[ $UNAME != Linux ] && have gsed && alias sed=gsed

# This function performs file and directory completion. It's better than
# simply using 'compgen -f', because it honours spaces in filenames.
# If passed -d, it completes only on directories. If passed anything else,
# it's assumed to be a file glob to complete on.
#
_filedir()
{
	local IFS=$'\t\n' xspec

	_expand || return 0

	if [ "${1:-}" = -d ]; then
		COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -d -- $cur ) )
		return 0
	fi

	xspec=${1:+"!*.$1"}	# set only if glob passed in as $1
	COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -f -X "$xspec" -- "$cur" ) \
		    $( compgen -d -- "$cur" ) )
}

# This function completes on signal names
#
_signals()
{
	local i

	# standard signal completion is rather braindead, so we need
	# to hack around to get what we want here, which is to
	# complete on a dash, followed by the signal name minus
	# the SIG prefix
	COMPREPLY=( $( compgen -A signal SIG${cur#-} ))
	for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
		COMPREPLY[i]=-${COMPREPLY[i]#SIG}
	done
}

# This function completes on network interfaces
#
_interfaces()
{
	if [ -f /etc/debian_version ]; then
		# Debian system
		COMPREPLY=( $( sed -ne 's|^iface \([^ ]\+\).*$|\1|p' \
			       /etc/network/interfaces ) )
	else
		# Assume Red Hat
		COMPREPLY=( $( command ls \
			/etc/sysconfig/network-scripts/ifcfg-* | \
			sed -ne 's|.*ifcfg-\('$cur'.*\)|\1|p' ) )
	fi
}

# This function expands tildes in pathnames
#
_expand()
{
	[ "$cur" != "${cur%\\}" ] && cur="$cur\\"

	# expand ~username type directory specifications
	if [[ "$cur" == \~*/* ]]; then
		eval cur=$cur
		
	elif [[ "$cur" == \~* ]]; then
		cur=${cur#\~}
		COMPREPLY=( $( compgen -P '~' -u $cur ) )
		return ${#COMPREPLY[@]}
	fi
}

# This function completes on process IDs
#
_pids()
{
	COMPREPLY=( $( compgen -W '$( command ps axo pid | sed 1d )' -- $cur ) )
}

# This function completes on process group IDs
#
_pgids()
{
	COMPREPLY=( $( compgen -W '$( command ps axo pgid | sed 1d )' -- $cur ))
}

# This function completes on user IDs
#
_uids()
{
	if type perl &>/dev/null; then
	    COMPREPLY=( $( compgen -W '$( perl -e '"'"'while (($uid) = (getpwent)[2]) { print $uid . "\n" }'"'"' )' -- $cur ) )
	else
	    # make do with /etc/passwd
	    COMPREPLY=( $( awk 'BEGIN {FS=":"} {if ($3 ~ /^'$cur'/) print $3}'\
			    /etc/passwd ) )
	fi
}

# This function completes on group IDs
#
_gids()
{
	if type perl &>/dev/null; then
	    COMPREPLY=( $( compgen -W '$( perl -e '"'"'while (($gid) = (getgrent)[2]) { print $gid . "\n" }'"'"' )' -- $cur ) )
	else
	    # make do with /etc/group
	    COMPREPLY=( $( awk 'BEGIN {FS=":"} {if ($3 ~ /^'$cur'/) print $3}'\
			    /etc/group ) )
	fi
}

# Linux ifconfig(8) and iwconfig(8) helper function
#
[ $UNAME = Linux -o $UNAME = FreeBSD ] && { have ifconfig || have iwconfig; } &&
_ifwconfig()
{
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	case "${COMP_WORDS[1]}" in
	-|*[0-9]*)
		#COMPREPLY=( $( compgen -W '${keywords[@]}' ) )
		COMPREPLY=( ${keywords[@]} )
		COMPREPLY=( $( echo " ${COMP_WORDS[@]}" | \
			       (while read -d ' ' i; do
				   [ "$i" == "" ] && continue
				   # flatten array with spaces on either side,
				   # otherwise we cannot grep on word
				   # boundaries of first and last word
				   COMPREPLY=" ${COMPREPLY[@]} "
				   # remove word from list of completions
				   COMPREPLY=( ${COMPREPLY/ $i / } )
				done
				echo ${COMPREPLY[@]})
			  ) )
		return 0
		;;
	esac

	COMPREPLY=( $( eval "$@" 2>/dev/null | \
			sed -ne \
			  's|^\('$cur'[^[:space:][:punct:]]\{1,\}\).*$|\1|p') )
}

# start of section containing completion functions for bash built-ins

# bash alias completion
#
_alias()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[$COMP_CWORD]}

	case "$COMP_LINE" in
	*[^=])
		COMPREPLY=( $( compgen -A alias -S '=' -- $cur ) )
		;;
	*=)
		COMPREPLY=( "$( alias ${cur%=} 2>/dev/null | \
			     sed -e 's|^alias '$cur'\(.*\)$|\1|' )" )
		;;
	esac
}
complete -F _alias alias

# bash export completion
#
_export()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[$COMP_CWORD]}

	case "$COMP_LINE" in
	*=\$*)
		COMPREPLY=( $( compgen -v -P '$' -- ${cur#*=\$} ) )
		;;
	*[^=])
		COMPREPLY=( $( compgen -v -S '=' -- $cur ) )
		;;
	*=)
		COMPREPLY=( "$( eval echo -n \"$`echo ${cur%=}`\" |
			( echo -n \'
			  sed -e 's/'\''/'\''\\\'\'''\''/g'
			  echo -n \' ) )" )
		;;
	esac
}
complete -F _export $default $nospace export

# bash shell function completion
#
_function()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ $1 == @(declare|typeset) ]]; then
		if [ "$prev" = -f ]; then
			COMPREPLY=( $( compgen -A function -- $cur ) )
		elif [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '-a -f -F -i -r -x -p' -- \
				       $cur ) )
		fi
	elif [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -A function -- $cur ) )
	else
		COMPREPLY=( "() $( type -- ${COMP_WORDS[1]} | sed -e 1,2d )" )
	fi
}
complete -F _function function declare typeset

# bash complete completion
#
_complete()
{
	local cur prev options

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case $prev in
		-o)
			options="default dirnames filenames"
			[ -n "$bash205b" ] && options="$options nospace"
			[ -n "$bash3" ] && options="$options bashdefault plusdirs"
			COMPREPLY=( $( compgen -W "$options" -- $cur ) )
			return 0
			;;

		-A)
			COMPREPLY=( $( compgen -W 'alias arrayvar binding \
				builtin command directory disabled enabled \
				export file function group helptopic hostname \
				job keyword running service setopt shopt \
				signal stopped user variable' -- $cur ) )
			return 0
			;;

		-C)
			COMPREPLY=( $( compgen -A command -- $cur ) )
			return 0
			;;
		-F)
			COMPREPLY=( $( compgen -A function -- $cur ) )
			return 0
			;;
		-@(p|r))
			COMPREPLY=( $( complete -p | sed -e 's|.* ||' | \
					grep "^$cur" ) )
			return 0
			;;

	esac

	if [[ "$cur" == -* ]]; then
		# relevant options completion
		options="-a -b -c -d -e -f -g -j -k -s -v -u -A -G -W -P -S -X -F -C"
		[ -n "$bash205" ] && options="$options -o"
		COMPREPLY=( $( compgen -W "$options" -- $cur ) )
	else
		COMPREPLY=( $( compgen -A command -- $cur ) )
	fi
}
complete -F _complete complete

# start of section containing completion functions for external programs

# a little help for FreeBSD ports users
[ $UNAME = FreeBSD ] && complete -W 'index search fetch fetch-list \
	extract patch configure build install reinstall \
	deinstall clean clean-depends kernel buildworld' make

# This completes on a list of all available service scripts for the
# 'service' command and/or the SysV init.d directory, followed by
# that script's available commands
#
{ have service || [ -d /etc/init.d/ ]; } &&
_service()
{
	local cur sysvdir

	COMPREPLY=()
	prev=${COMP_WORDS[COMP_CWORD-1]}
	cur=${COMP_WORDS[COMP_CWORD]}

	# don't complete for things like killall, ssh and mysql if it's
	# the standalone command, rather than the init script
	[[ ${COMP_WORDS[0]} != @(*init.d/!(functions|~)|service) ]] && return 0

	# don't complete past 2nd token
	[ $COMP_CWORD -gt 2 ] && return 0

	[ -d /etc/rc.d/init.d ] && sysvdir=/etc/rc.d/init.d \
				|| sysvdir=/etc/init.d

	if [[ $COMP_CWORD -eq 1 ]] && [[ $prev == "service" ]]; then
		COMPREPLY=( $( compgen -W '`echo $sysvdir/!(*.rpmsave|*.rpmorig)`' ) )
		COMPREPLY=( $( compgen -W '${COMPREPLY[@]#$sysvdir/}' -- \
			       $cur ) )
	else
		COMPREPLY=( $( compgen -W '`sed -ne "y/|/ /; \
					    s/^.*Usage.*{\(.*\)}.*$/\1/p" \
					    $sysvdir/${prev##*/}`' -- \
			       $cur ) )
	fi

	return 0
}
[ -n "${have:-}" ] && complete -F _service service
[ -d /etc/init.d/ ] && complete -F _service $default \
	$(for i in /etc/init.d/*; do echo ${i##*/}; done)

# chown(1) completion
#
_chown()
{
	local user
	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD-1]}

	# options completion
	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-c -h -f -R -v --changes \
		--dereference --no-dereference --from= --silent --quiet \
		--reference= --recursive --verbose --help --version' -- $cur ) )
		return 0
	fi

	if (( COMP_CWORD == 1 )) || [[ "$prev" == -* ]]; then
	    if [[ $cur = *@(\\:|.)* ]] && [ -n "$bash205" ]; then
		user=${cur%%*([^:.])}
		COMPREPLY=( $(compgen -P ${user/\\\\} -g -- ${cur##*[.:]}) )
	    elif [[ $cur = *:* ]] && [ -n "$bash205" ]; then
		COMPREPLY=( $( compgen -g -- ${cur##*[.:]} ) )
	    else
		COMPREPLY=( $( compgen -S : -u -- $cur ) )
	    fi
	else
	    _filedir
	fi
}
complete -F _chown $filenames chown

# chgrp(1) completion
#
_chgrp()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	# options completion
	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-c -h -f -R -v --changes \
		--dereference --no-dereference --silent --quiet \
		--reference= --recursive --verbose --help --version' -- $cur ) )
		return 0
	fi

	# first parameter on line or first since an option?
	if [ $COMP_CWORD -eq 1 ] && [[ "$cur" != -* ]] || \
	   [[ "$prev" == -* ]] && [ -n "$bash205" ]; then
		COMPREPLY=( $( compgen -g $cur 2>/dev/null ) )
	else
		_expand || return 0
	fi

	return 0
}
complete -F _chgrp $default chgrp

# umount(8) completion. This relies on the mount point being the third
# space-delimited field in the output of mount(8)
#
_umount()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=( $( compgen -W '$( mount | cut -d" " -f 3 )' -- $cur ) )

	return 0
}
complete -F _umount $dirnames umount

# mount(8) completion. This will pull a list of possible mounts out of
# /etc/{,v}fstab, unless the word being completed contains a ':', which
# would indicate the specification of an NFS server. In that case, we
# query the server for a list of all available exports and complete on
# that instead.
#
_mount()
{       local cur i sm host

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	[[ "$cur" == \\ ]] && cur="/"

	for i in {,/usr}/{,s}bin/showmount; do [ -x $i ] && sm=$i && break; done

	if [ -n "$sm" ] && [[ "$cur" == *:* ]]; then
		COMPREPLY=( $( $sm -e ${cur%%:*} | sed 1d | \
			       grep ^${cur#*:} | awk '{print $1}' ) )
	elif [[ "$cur" == //* ]]; then
		host=${cur#//}
		host=${host%%/*}
		if [ -n "$host" ]; then
			COMPREPLY=( $( compgen -W "$( echo $( smbclient -d 0 -NL $host |
			sed -ne '/^['$'\t '']*Sharename/,/^$/p' |
			sed -ne '3,$s|^[^A-Za-z]*\([^'$'\t '']*\).*$|//'$host'/\1|p' ) )" -- "$cur" ) )
		fi
	elif [ -r /etc/vfstab ]; then
		# Solaris
		COMPREPLY=( $( awk '! /^[ \t]*#/ {if ($3 ~ /\//) print $3}' \
				/etc/vfstab | grep "^$cur" ) )
	else
		# probably Linux
		COMPREPLY=( $( awk '! /^[ \t]*#/ {if ($2 ~ /\//) print $2}' \
				/etc/fstab | grep "^$cur" ) )
	fi

	return 0
}
complete -F _mount $default $filenames mount

# Linux rmmod(8) completion. This completes on a list of all currently
# installed kernel modules.
#
have rmmod && {
_rmmod()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=( $( /sbin/lsmod | \
		  awk '{if (NR != 1 && $1 ~ /^'$cur'/) print $1}' 2>/dev/null ))
	return 0
}
complete -F _rmmod rmmod

# Linux insmod(8), modprobe(8) and modinfo(8) completion. This completes on a
# list of all available modules for the version of the kernel currently
# running.
#
_insmod()
{
	local cur prev modpath

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	modpath=/lib/modules/`uname -r`

	# behave like lsmod for modprobe -r
	if [ $1 = "modprobe" ] &&
	   [ "${COMP_WORDS[1]}" = "-r" ]; then
		COMPREPLY=( $( /sbin/lsmod | \
				awk '{if (NR != 1 && $1 ~ /^'$cur'/) print $1}' ) )
		return 0
	fi

	# do filename completion if we're giving a path to a module
	if [[ "$cur" == ?(.|..)/* ]]; then
		_filedir
		return 0
	fi

	if [ $COMP_CWORD -gt 1 ] && 
	   [[ "${COMP_WORDS[COMP_CWORD-1]}" != -* ]]; then
		# do module parameter completion
		COMPREPLY=( $( /sbin/modinfo -p ${COMP_WORDS[1]} 2>/dev/null | \
		       awk '{if ($1 ~ /^parm:/ && $2 ~ /^'$cur'/) { print $2 } \
			else if ($1 !~ /:/ && $1 ~ /^'$cur'/) { print $1 }}' ) )
	elif [ -r $modpath -a -x $modpath ]; then
		# do module name completion
		COMPREPLY=( $( command ls -R $modpath | \
			sed -ne 's/^\('$cur'.*\)\.k\?o\(\|.gz\)$/\1/p') )
	else 
		_filedir
	fi

	return 0
}
complete -F _insmod $filenames insmod modprobe modinfo
}

# man(1) completion
#
[ $UNAME = GNU -o $UNAME = Linux -o $UNAME = Darwin \
  -o $UNAME = FreeBSD -o $UNAME = SunOS -o $UNAME = Cygwin ] &&
_man()
{
	local cur prev sect manpath UNAME

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	_expand || return 0

	# default completion if parameter contains /
	if [[ "$cur" == */* ]]; then
		_filedir
		return 0
	fi

	UNAME=$( uname -s )
	# strip OS type and version under Cygwin
	UNAME=${UNAME/CYGWIN_*/Cygwin}
	if [ $UNAME = GNU -o $UNAME = Linux -o $UNAME = FreeBSD \
	     -o $UNAME = Cygwin ]; then
		manpath=$( manpath 2>/dev/null || command man --path )
	else
		manpath=$MANPATH
	fi

	if [ -z "$manpath" ]; then
		COMPREPLY=( $( compgen -c -- $cur ) )
		return 0
	fi

	# determine manual section to search
	[[ "$prev" == [0-9ln] ]] && sect=$prev || sect='*'

	manpath=$manpath:
	if [ -n "$cur" ]; then
		manpath="${manpath//://*man$sect/$cur* }"
	else
		manpath="${manpath//://*man$sect/ }"
	fi
		
	# redirect stderr for when path doesn't exist
	COMPREPLY=( $( eval command ls "$manpath" 2>/dev/null ) )
	# weed out directory path names and paths to man pages
	COMPREPLY=( ${COMPREPLY[@]##*/?(:)} )
	# strip suffix from man pages
	COMPREPLY=( ${COMPREPLY[@]%.@(gz|bz2)} )
	COMPREPLY=( $( compgen -W '${COMPREPLY[@]%.*}' -- "${cur//\\\\/}" ) )

	[[ "$prev" != [0-9ln] ]] && _filedir '[0-9ln]'

	return 0
}
[ $UNAME = GNU -o $UNAME = Linux -o $UNAME = Darwin \
  -o $UNAME = FreeBSD -o $UNAME = SunOS -o $UNAME = Cygwin ] && \
complete -F _man $filenames man

# renice(8) completion
#
_renice()
{
	local command cur curopt i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	command=$1

	i=0
	# walk back through command line and find last option
	while [ $i -le $COMP_CWORD -a ${#COMPREPLY[@]} -eq 0 ]; do
		curopt=${COMP_WORDS[COMP_CWORD-$i]}
		case "$curopt" in
		-u)
			COMPREPLY=( $( compgen -u -- $cur ) )
			;;
		-g)
			_pgids
			;;
		-p|$command)
			_pids
			;;
		esac
		i=$(( ++i ))
	done
}
complete -F _renice renice

# kill(1) completion
#
_kill()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ] && [[ "$cur" == -* ]]; then
		# return list of available signals
		_signals
	else
		# return list of available PIDs
		_pids
	fi
}
complete -F _kill kill

# Linux and FreeBSD killall(1) completion.
#
[ $UNAME = Linux -o $UNAME = FreeBSD ] &&
_killall()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ] && [[ "$cur" == -* ]]; then
		_signals
	else
		COMPREPLY=( $( compgen -W '$( command ps axo command | \
			      sed -ne "1d; s/^\[\?\([^-][^] ]*\).*$/\1/p" | \
			      sed -e "s/.*\///" )' -- $cur ) )
	fi

	return 0
}
[ $UNAME = Linux -o $UNAME = FreeBSD ] && complete -F _killall killall pkill

# GNU find(1) completion. This makes heavy use of ksh style extended
# globs and contains Linux specific code for completing the parameter
# to the -fstype option.
#
_find()
{
	local cur prev i exprfound onlyonce

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-@(max|min)depth)
		COMPREPLY=( $( compgen -W '0 1 2 3 4 5 6 7 8 9' -- $cur ) )
		return 0
		;;
	-?(a|c)newer|-fls|-fprint?(0|f)|-?(i)?(l)name)
		_filedir
		return 0
		;;
	-fstype)
		# this is highly non-portable
		COMPREPLY=( $( cut -d$'\t' -f 2 /proc/filesystems | \
				grep "^$cur" ) )
		return 0
		;;
	-gid)
		_gids
		return 0
		;;
	-group)
		if [ -n "$bash205" ]; then
			COMPREPLY=( $( compgen -g -- $cur 2>/dev/null) )
		fi
		return 0
		;;
	-?(x)type)
		COMPREPLY=( $( compgen -W 'b c d p f l s' -- $cur ) )
		return 0
		;;
	-uid)
		_uids
		return 0
		;;
	-user)
		COMPREPLY=( $( compgen -u -- $cur ) )
		return 0
		;;
	-exec|-ok)
		COMP_WORDS=(COMP_WORDS[0] $cur)
		COMP_CWORD=1
		_command
		return 0
		;;
	-[acm]min|-[acm]time|-?(i)?(l)name|-inum|-?(i)path|-?(i)regex| \
	-links|-perm|-size|-used|-printf)
		# do nothing, just wait for a parameter to be given
		return 0
		;;
	esac

	_expand || return 0

	# set exprfound to 1 if there is already an expression present
	for i in ${COMP_WORDS[@]}; do
		[[ "$i" = [-\(\),\!]* ]] && exprfound=1 && break
	done

	# handle case where first parameter is not a dash option
	if [ "$exprfound" != 1 ] && [[ "$cur" != [-\(\),\!]* ]]; then
		_filedir -d
		return 0
	fi

	# complete using basic options
	COMPREPLY=( $( compgen -W '-daystart -depth -follow -help -maxdepth \
			-mindepth -mount -noleaf -version -xdev -amin -anewer \
			-atime -cmin -cnewer -ctime -empty -false -fstype \
			-gid -group -ilname -iname -inum -ipath -iregex \
			-links -lname -mmin -mtime -name -newer -nouser \
			-nogroup -perm -regex -size -true -type -uid -used \
			-user -xtype -exec -fls -fprint -fprint0 -fprintf -ok \
			-print -print0 -printf -prune -ls' -- $cur ) )

	# this removes any options from the list of completions that have
	# already been specified somewhere on the command line, as long as
	# these options can only be used once (in a word, "options", in
	# opposition to "tests" and "actions", as in the find(1) manpage).
	onlyonce=' -daystart -depth -follow -help -maxdepth -mindepth -mount \
		   -noleaf -version -xdev '
	COMPREPLY=( $( echo "${COMP_WORDS[@]}" | \
		       (while read -d ' ' i; do
			    [ "$i" == "" ] ||
			    [ "${onlyonce/ ${i%% *} / }" == "$onlyonce" ] &&
			    continue
			    # flatten array with spaces on either side,
			    # otherwise we cannot grep on word boundaries of
			    # first and last word
			    COMPREPLY=" ${COMPREPLY[@]} "
			    # remove word from list of completions
			    COMPREPLY=( ${COMPREPLY/ ${i%% *} / } )
			done
			echo ${COMPREPLY[@]})
		  ) )
	
	_filedir
	
	return 0
}
complete -F _find $filenames find

# Linux ifconfig(8) completion
#
[ $UNAME = Linux -o $UNAME = FreeBSD ] && have ifconfig &&
_ifconfig()
{
	local cur
	local -a keywords=( -a up down arp promisc allmulti metric mtu dstaddr \
			    netmask add del tunnel irq io_addr mem_start media \
			 broadcast pointopoint hw multicast address txqueuelen )

	_ifwconfig ifconfig -a

	COMPREPLY=( $( compgen -W '${COMPREPLY[@]}' -- $cur ) )
}
[ $UNAME = Linux -o $UNAME = FreeBSD ] && have ifconfig &&
  complete -F _ifconfig ifconfig

# Linux iwconfig(8) completion
#
[ $UNAME = Linux ] && have iwconfig &&
_iwconfig()
{
	local -a keywords=( essid nwid domain freq channel sens mode ap nick \
			    rate bit rts frag key enc power )

	_ifwconfig iwconfig

	COMPREPLY=( $( compgen -W '${COMPREPLY[@]}' -- $cur ) )
}
[ $UNAME = Linux ] && complete -F _iwconfig iwconfig

# RedHat & Debian GNU/Linux if{up,down} completion
#
[ $UNAME = Linux ] && ( have ifup || have ifdown ) &&
_ifupdown()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ]; then
		_interfaces
       fi

       return 0
}
[ $UNAME = Linux ] && have ifup && complete -F _ifupdown ifup ifdown

# Linux ipsec(8) completion (for FreeS/WAN)
#
[ $UNAME = Linux ] && have ipsec &&
_ipsec()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	
	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -W 'auto barf eroute klipsdebug look \
					   manual pluto ranbits rsasigkey \
					   setup showdefaults showhostkey spi \
					   spigrp tncfg whack' -- $cur ) )
		return 0
	fi

	case ${COMP_WORDS[1]} in
	auto)
		COMPREPLY=( $( compgen -W '--asynchronous --up --add --delete \
					   --replace --down --route --unroute \
					   --ready --status --rereadsecrets' \
					-- $cur ) )
		;;
	manual)
		COMPREPLY=( $( compgen -W '--up --down --route --unroute \
					   --union' -- $cur ) )
		;;
	ranbits)
		COMPREPLY=( $( compgen -W '--quick --continuous --bytes' \
					  -- $cur ) )
		;;
	setup)
		COMPREPLY=( $( compgen -W '--start --stop --restart' -- $cur ) )
		;;

	*)
		;;
	esac

	return 0
}
[ $UNAME = Linux ] && [ -n "${have:-}" ] && complete -F _ipsec ipsec

# Postfix completion.
#
have postfix && {
# postfix(1)
#
_postfix()
{
	local cur prev

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ $cur == '-' ]]; then
		COMPREPLY=(-c -D -v)
		return 0
	fi
	if [[ $prev == '-c' ]]; then
		_filedir -d
		return 0
	fi
	if [[ $prev == '-D' ]]; then
		COMPREPLY=( $( compgen -W 'start' -- "${COMP_WORDS[COMP_CWORD]}" ) )
		return 0
	fi
	COMPREPLY=( $( compgen -W 'start stop reload abort flush check' -- \
		"${COMP_WORDS[COMP_CWORD]}" ) )
}
complete -F _postfix postfix

# postalias(1) and postmap(1)
#
_postmap()
{
	local cur prev len idx

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ $cur == '-' ]]; then
		COMPREPLY=(-N -f -i -n -o -p -r -v -w -c -d -q)
		return 0
	fi
	if [[ $prev == '-c' ]]; then
		_filedir -d
		return 0
	fi
	if [[ $prev == -[dq] ]]; then
		return 0
	fi

	if [[ "$cur" == *:* ]]; then
	       	COMPREPLY=( $( compgen -f -- ${cur#*:} ) )
	else
		len=${#cur}
		idx=0
		for pval in $( /usr/sbin/postconf -m ); do
			if [[ "$cur" == "${pval:0:$len}" ]]; then
				COMPREPLY[$idx]="$pval:"
				idx=$(($idx+1))
			fi
		done
		if [[ $idx -eq 0 ]]; then
			COMPREPLY=( $( compgen -f -- "$cur" ) )
		fi
	fi
	return 0
}
complete -F _postmap postmap postalias

# postcat(1)
#
_postcat()
{
	local cur prev pval len idx qfile

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ $cur == '-' ]]; then
		COMPREPLY=(-c -q -v)
		return 0
	fi
	if [[ $prev == '-c' ]]; then
		_filedir -d
		return 0
	fi

	qfile=0
	for idx in ${COMP_WORDS[@]}; do
		[[ "$idx" = -q ]] && qfile=1 && break
	done
	if [[ $qfile == 1 ]]; then
		len=${#cur}
		idx=0
		for pval in $( mailq | \
			sed -e '1d; $d; /^[^0-9A-Z]\|^$/d; s/[* !].*$//' ); do
			if [[ "$cur" == "${pval:0:$len}" ]]; then
				COMPREPLY[$idx]=$pval
				idx=$(($idx+1))
			fi
		done
		return 0
	else
		_filedir
		return 0
	fi
}
complete -F _postcat postcat

# postconf(1)
#
_postconf()
{
	local cur prev pval len idx eqext

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	if [[ $cur == '-' ]]; then
		COMPREPLY=(-c -d -e -h -m -l -n -v)
		return 0
	fi
	if [[ $prev == '-c' ]]; then
		_filedir -d
		return 0
	fi
	if [[ $prev == '-e' ]]; then
		cur=${cur#[\"\']}
		eqext='='
	fi
	len=${#cur}
	idx=0
	for pval in $( /usr/sbin/postconf | cut -d ' ' -f 1 ); do
		if [[ "$cur" == "${pval:0:$len}" ]]; then
			COMPREPLY[$idx]="$pval$eqext"
			idx=$(($idx+1))
		fi
	done
	return 0
}
complete -F _postconf postconf

# postsuper(1)
#
_postsuper()
{
	local cur prev pval len idx

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ $cur == '-' ]]; then
		COMPREPLY=(-c -d -h -H -p -r -s -v)
		return 0
	fi
	case $prev in
	-[dr])
		len=${#cur}
		idx=0
		for pval in $( echo ALL; mailq | \
			sed -e '1d; $d; /^[^0-9A-Z]\|^$/d; s/[* !].*$//' ); do
			if [[ "$cur" == "${pval:0:$len}" ]]; then
				COMPREPLY[$idx]=$pval
				idx=$(($idx+1))
			fi
		done
		return 0
		;;
	-h)
		len=${#cur}
		idx=0
		for pval in $( echo ALL; mailq | \
			sed -e '1d; $d; /^[^0-9A-Z]\|^$/d; s/[* ].*$//; /!$/d' ); do
			if [[ "$cur" == "${pval:0:$len}" ]]; then
				COMPREPLY[$idx]=$pval
				idx=$(($idx+1))
			fi
		done
		return 0
		;;
	-H)
		len=${#cur}
		idx=0
		for pval in $( echo ALL; mailq | \
			sed -e '1d; $d; /^[^0-9A-Z]\|^$/d; /^[0-9A-Z]*[* ]/d; s/!.*$//' ); do
			if [[ "$cur" == "${pval:0:$len}" ]]; then
				COMPREPLY[$idx]=$pval
				idx=$(($idx+1))
			fi
		done
		return 0
		;;
	esac
	COMPREPLY=( $( compgen -W 'hold incoming active deferred' -- $cur ) )
	return 0
}
complete -F _postsuper postsuper
}

# cvs(1) completion
#
have cvs && {
set_prefix()
{
	[ -z ${prefix:-} ] || prefix=${cur%/*}/
	[ -r ${prefix:-}CVS/Entries ] || prefix=""
}

get_entries()
{
	[ -r ${prefix:-}CVS/Entries ] && \
	entries=( $( compgen -W \
		"$( echo $( cut -d/ -f2 -s ${prefix:-}CVS/Entries ) )" -- $cur ) )
}

get_modules()
{
	if [ -n "$prefix" ]; then 
		COMPREPLY=( $( command ls -d ${cvsroot}/${prefix}/!(CVSROOT) ) )
	else
		COMPREPLY=( $( command ls -d ${cvsroot}/!(CVSROOT) ) )
	fi
}

_cvs()
{
	local cur count mode i cvsroot cvsroots pwd
	local -a flags miss files entries changed newremoved

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	count=0
	for i in ${COMP_WORDS[@]}; do
		[ $count -eq $COMP_CWORD ] && break
		# Last parameter was the CVSROOT, now go back to mode selection
		if [ "${COMP_WORDS[((count))]}" == "$cvsroot" -a "$mode" == "cvsroot" ]; then
			mode=""
		fi
		if [ -z "$mode" ]; then
			case $i in
			-d)
				mode=cvsroot
				cvsroot=${COMP_WORDS[((count+1))]}
				;;
			@(ad?(d)|new))
				mode=add
				;;
			@(adm?(in)|rcs))
				mode=admin
				;;
			ann?(notate))
				mode = annotate
				;;
			@(checkout|co|get))
				mode=checkout
				;;
			@(com?(mit)|ci))
				mode=commit
				;;
			di?(f?(f)))
				mode=diff
				;;
			ex?(p?(ort)))
				mode=export
				;;
			?(un)edit)
				mode=$i
				;;
			hi?(s?(tory)))
				mode=history
				;;
			im?(p?(ort)))
				mode=import
				;;
			re?(l?(ease)))
				mode=release
				;;
			?(r)log)
				mode=log
				;;
			@(rdiff|patch))
				mode=rdiff
				;;
			@(remove|rm|delete))
				mode=remove
				;;
			@(rtag|rfreeze))
				mode=rtag
				;;
			st?(atus))
				mode=status
				;;
			@(tag|freeze))
				mode=tag
				;;
			up?(d?(ate)))
				mode=update
				;;
			*)
				;;
			esac
		elif [[ "$i" = -* ]]; then
			flags=( ${flags[@]:-} $i )
		fi
		count=$((++count))
	done

	case "$mode" in
	add)
		if [[ "$cur" != -* ]]; then
			set_prefix
			if [ $COMP_CWORD -gt 1 -a -r ${prefix:-}CVS/Entries ]; then
				get_entries
				[ -z "$cur" ] && \
				files=$( command ls -Ad !(CVS) ) || \
				files=$( command ls -d ${cur}* 2>/dev/null )
				for i in ${entries[@]:-}; do
					files=( ${files[@]/#$i//} )
				done
				COMPREPLY=( $( compgen -W '${files[@]}' -- \
					       $cur ) )
			fi
		else
			COMPREPLY=( $( compgen -W '-k -m' -- $cur ) )
		fi
		;;
	admin)
		if [[ "$cur" = -* ]]; then
			COMPREPLY=( $( compgen -W '-i -a -A -e -b -c -k -l -u \
						   -L -U -m -M -n -N -o -q -I \
						   -s -t -t- -T -V -x -z' -- \
					$cur ) )
		fi
		;;
	checkout)
		if [[ "$cur" != -* ]]; then
			[ -z "$cvsroot" ] && cvsroot=$CVSROOT
			COMPREPLY=( $( cvs -d "$cvsroot" co -c | awk '{print $1}' ) )
			COMPREPLY=( $( compgen -W '${COMPREPLY[@]}' -- $cur ) )
		else
			COMPREPLY=( $( compgen -W '-A -N -P -R -c -f -l -n -p \
						  -s -r -D -d -k -j' -- $cur ) )
		fi
		;;
	commit)
		set_prefix

		if [[ "$cur" != -* ]] && [ -r ${prefix:-}CVS/Entries ]; then
			# if $COMP_CVS_REMOTE is not null, 'cvs commit' will
			# complete on remotely checked-out files (requires
			# passwordless access to the remote repository
			if [ -n "${COMP_CVS_REMOTE:-}" ]; then
				# this is the least computationally intensive
				# way found so far, but other changes
				# (something other than changed/removed/new)
				# may be missing
				changed=( $( cvs diff --brief 2>&1 | \
				sed -ne 's/^Files [^ ]* and \([^ ]*\) differ$/\1/p' ) )
				newremoved=( $( cvs diff --brief 2>&1 | \
				sed -ne 's/^cvs diff: \([^ ]*\) .*, no comparison available$/\1/p' ) )
				COMPREPLY=( $( compgen -W '${changed[@]:-} \
						   ${newremoved[@]:-}' -- $cur ) )
			else
				COMPREPLY=( $( compgen -f -- $cur ) )
			fi
		else
			COMPREPLY=( $( compgen -W '-n -R -l -f -F -m -r' -- \
				       $cur ) )
		fi
		;;
	cvsroot)
		if [ -r ~/.cvspass ]; then
			# Ugly escaping because of bash treating ':' specially
			cvsroots=$( sed 's/^[^ ]* //; s/:/\\:/g' ~/.cvspass )
			COMPREPLY=( $( compgen -W '$cvsroots' -- $cur ) )
		fi
		;;
	export)
		if [[ "$cur" != -* ]]; then
			[ -z "$cvsroot" ] && cvsroot=$CVSROOT
			COMPREPLY=( $( cvs -d "$cvsroot" co -c | awk '{print $1}' ) )
			COMPREPLY=( $( compgen -W '${COMPREPLY[@]}' -- $cur ) )
		else
			COMPREPLY=( $( compgen -W '-N -f -l -R -n \
						  -r -D -d -k' -- $cur ) )
		fi
		;;
	diff)
		if [[ "$cur" == -* ]]; then
			_longopt diff
		else
			get_entries
			COMPREPLY=( ${entries[@]:-} )
		fi
		;;
	remove)
		if [[ "$cur" != -* ]]; then
			set_prefix
			if [ $COMP_CWORD -gt 1 -a -r ${prefix:-}CVS/Entries ]; then
				get_entries
				# find out what files are missing
				for i in ${entries[@]}; do
					[ ! -r "$i" ] && miss=( ${miss[@]:-} $i )
				done
				COMPREPLY=( $(compgen -W '${miss[@]:-}' -- $cur) )
			fi
		else
			COMPREPLY=( $( compgen -W '-f -l -R' -- $cur ) )
		fi
		;;
	import)
		if [[ "$cur" != -* ]]; then
			# starts with same algorithm as checkout
			[ -z "$cvsroot" ] && cvsroot=$CVSROOT
			prefix=${cur%/*}
			if [ -r ${cvsroot}/${prefix} ]; then
				get_modules
				COMPREPLY=( ${COMPREPLY[@]#$cvsroot} )
				COMPREPLY=( ${COMPREPLY[@]#\/} )
			fi
			pwd=$( pwd )
			pwd=${pwd##*/}
			COMPREPLY=( $( compgen -W '${COMPREPLY[@]} $pwd' -- \
				       $cur ) )
		else
			COMPREPLY=( $( compgen -W '-d -k -I -b -m -W' -- $cur ))
		fi
		;;
	"")
		COMPREPLY=( $( compgen -W 'add admin annotate checkout ci co \
					   commit diff delete edit export \
					   freeze get history import log new \
					   patch rcs rdiff release remove \
					   rfreeze rlog rm rtag status tag \
					   unedit up update -H -Q -q -b -d -e \
					   -f -l -n -t -r -v -w -x -z --help \
					   --version' -- $cur ) )
		;;
	*)
		;;
	esac
	
	return 0
}
complete -F _cvs $default cvs
}

have rpm && {
# helper functions for rpm completion
#
_rpm_installed_packages()
{
	local i

	if [ -r /var/log/rpmpkgs -a \
		/var/log/rpmpkgs -nt /var/lib/rpm/Packages ]; then
		# using RHL 7.2 or later - this is quicker than querying the DB
		COMPREPLY=( $( sed -ne \
		's|^\('$cur'.*\)-[0-9a-zA-Z._]\+-[0-9a-z.@]\+.*\.rpm$|\1|p' \
				/var/log/rpmpkgs ) )
	else
		COMPREPLY=( $( rpm -qa $options | sed -ne \
		's|^\('$cur'.*\)-[0-9a-zA-Z._]\+-[0-9a-z.@]\+$|\1|p' ) )
	fi
}

_rpm_groups()
{
	local IFS=$'\t'
	# remove trailing backslash, or grep will complain
	cur=${cur%"\\"}
	COMPREPLY=( $( rpm -qa $options --queryformat '%{group}\n' | \
		       grep "^$cur" ) )
	# backslash escape spaces and translate newlines to tabs
	COMPREPLY=( $( echo ${COMPREPLY[@]} | sed 's/ /\\ /g' | tr '\n' '\t' ) )
}

# rpm(8) completion
# 
_rpm()
{
	local cur prev ver options

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	options=""
	ver=$(rpm --version); ver=${ver##* }
  
	if [[ "$ver" > "4.0.4" ]]; then
		options="--nodigest"
	fi
	if [[ "$ver" > "4.0.99" ]]; then
		options="$options --nosignature"
	fi

	if [ $COMP_CWORD -eq 1 ]; then
		# first parameter on line
		case "$cur" in
		-b*)
			COMPREPLY=( $( compgen -W '-ba -bb -bc -bi -bl -bp -bs'\
				       -- $cur ) )
			;;
		-t*)
			COMPREPLY=( $( compgen -W '-ta -tb -tc -ti -tl -tp -ts'\
				       -- $cur ) )
			;;
		--*)
			COMPREPLY=( $( compgen -W '--help --version --initdb \
			--checksig --recompile --rebuild --resign --addsign \
			--rebuilddb --showrc --setperms --setugids --tarbuild \
			--eval --install --upgrade --query --freshen --erase \
			--verify --querytags --rmsource --rmspec --clean \
			--import' -- $cur ) )
			;;
		*)
			COMPREPLY=( $( compgen -W '-b -e -F -i -q -t -U -V' \
				       -- $cur ) )
			;;
		esac

	return 0
	fi

	case "$prev" in
	--@(@(db|exclude)path|prefix|relocate|root))
		_filedir -d
		return 0
		;;
	--eval)
		# get a list of macros
		COMPREPLY=( $( sed -ne 's|^\(%'${cur#\%}'[^ '$'\t'']*\).*$|\1|p' \
			       /usr/lib/rpm/macros ) )
		return 0
		;;
	--pipe)
		COMPREPLY=( $( compgen -c -- $cur ) )
		return 0
		;;
	--rcfile)
		_filedir
		return 0
		;;
	--specfile)
		# complete on .spec files
		_filedir spec
		return 0
		;;
	--whatprovides)
		if [[ "$cur" == */* ]]; then
			_filedir
		else
		# complete on capabilities
			COMPREPLY=( $( rpm -qa $options --queryformat \
					'%{providename}\n' | grep "^$cur" ) )
		fi
		return 0
		;;
	--whatrequires)
		# complete on capabilities
		COMPREPLY=( $( rpm -qa $options --queryformat \
				'%{requirename}\n' | grep "^$cur" ) )
		return 0
		;;
	esac

	case "${COMP_WORDS[1]}" in
	-@([iFU]*|-install|-freshen|-upgrade))
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--percent --force --test \
			--replacepkgs --replacefiles --root --excludedocs \
			--includedocs --noscripts --rcfile --ignorearch \
			--dbpath --prefix --ignoreos --nodeps --allfiles \
			--ftpproxy --ftpport --justdb --httpproxy --httpport \
			--noorder --relocate --badreloc --notriggers \
			--excludepath --ignoresize --oldpackage --define \
			--eval --pipe --queryformat --repackage --nosuggests \
			--nodigest --nosignature' -- $cur ) )
		else
			_filedir 'rpm'
		fi
		;;
	-@(e|-erase))
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--allmatches --noscripts \
			--notriggers --nodeps --test --repackage' -- $cur ) )
		else
			_rpm_installed_packages
		fi
		;;
	-@(q*|-query))
		# check whether we're doing file completion
		if [ "${COMP_LINE#* -*([^ -])f}" != "$COMP_LINE" ]; then
		    if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--scripts --root \
				--rcfile --requires --ftpport --ftpproxy \
				--httpproxy --httpport --provides --triggers \
				--dump --changelog --dbpath \
				--last --filesbypkg \
				--info --list --state \
				--docfiles --configfiles --queryformat \
				--conflicts --obsoletes \
				--nodigest --nosignature \
				--triggerscripts' -- $cur ) )
		    else
			_filedir
		    fi
		elif [ "${COMP_LINE#* -*([^ -])g}" != "$COMP_LINE" ]; then
			_rpm_groups
		elif [ "${COMP_LINE#* -*([^ -])p}" != "$COMP_LINE" ]; then
			# uninstalled package completion
			if [[ "$cur" == -* ]]; then
				COMPREPLY=( $( compgen -W '--scripts --root \
				--rcfile --whatprovides --whatrequires \
				--requires --triggeredby --ftpport --ftpproxy \
				--httpproxy --httpport --provides --triggers \
				--dump --changelog --dbpath --filesbypkg \
				--define --eval --pipe --showrc --info --list \
				--state --docfiles --configfiles --queryformat\
				--conflicts --obsoletes --nodigest \
				--nosignature' -- $cur ) )
			else
				_filedir 'rpm'
			fi
		else
			# installed package completion
			if [[ "$cur" == -* ]]; then
				COMPREPLY=( $( compgen -W '--scripts --root \
				--rcfile --whatprovides --whatrequires \
				--requires --triggeredby --ftpport --ftpproxy \
				--httpproxy --httpport --provides --triggers \
				--dump --changelog --dbpath --specfile \
				--querybynumber --last --filesbypkg --define \
				--eval --pipe --showrc --info --list --state \
				--docfiles --configfiles --queryformat \
				--conflicts --obsoletes --pkgid --hdrid \
				--fileid --tid --nodigest --nosignature \
				--triggerscripts' -- $cur ) )
			elif [ "${COMP_LINE#* -*([^ -])a}" == "$COMP_LINE" ]; then
				_rpm_installed_packages
			fi
		fi
		;;
	-@(K*|-checksig))
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--nopgp --nogpg --nomd5 \
					--nodigest --nosignature' -- $cur ) )
		else
			_filedir 'rpm'
		fi
		;;
	-@([Vy]*|-verify))
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--root --rcfile --dbpath \
			--nodeps --nogroup --nolinkto --nomode --nomtime \
			--nordev --nouser --nofiles --noscripts --nomd5 \
			--querytags --specfile --whatrequires --whatprovides \
			--nodigest --nosignature' -- $cur ) )
		# check whether we're doing file completion
		elif [ "${COMP_LINE#* -*([^ -])f}" != "$COMP_LINE" ]; then
			_filedir
		elif [ "${COMP_LINE#* -*([^ -])g}" != "$COMP_LINE" ]; then
			_rpm_groups
		elif [ "${COMP_LINE#* -*([^ -])p}" != "$COMP_LINE" ]; then
			_filedir 'rpm'
		else
			_rpm_installed_packages
		fi
		;;
	-[bt]*)
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--short-circuit --timecheck \
			--clean --rmsource --rmspec --test --sign --buildroot \
			--target -- buildarch --buildos --nobuild --nodeps \
			--nodirtokens' -- $cur ) )
		elif [[ ${COMP_WORDS[1]} == -b* ]]; then
			_filedir 'spec'
		else
			_filedir '@(tgz|tar.@(gz|bz2))'
		fi
		;;
	--re@(build|compile))
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--nodeps --rmsource \
			  --rmspec --sign --nodirtokens --target' -- $cur ) )
		else
			_filedir '?(no)src.rpm'
		fi
		;;
	--tarbuild)
		_filedir '@(tgz|tar.@(gz|bz2))'
		;;
	--@(re|add)sign)
		_filedir 'rpm'
		;;
	--set@(perms|gids))
		_rpm_installed_packages
		;;
	--@(clean|rms@(ource|pec)))
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--clean --rmsource \
					--rmspec' -- $cur ) )
		else
			_filedir 'spec'
		fi
		;;
	--@(import|dbpath|root))
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $( compgen -W '--import --dbpath --root' \
					-- $cur ) )
		else
			_filedir
		fi
		;;
	esac

	return 0
}
complete -F _rpm $filenames rpm rpmbuild
}

# Debian apt-get(8) completion.
#
have apt-get &&
_apt_get()
{
	local cur prev special i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
		if [[ ${COMP_WORDS[i]} == @(install|remove|source|build-dep) ]]; then
			special=${COMP_WORDS[i]}
		fi
	done

	if [ -n "$special" ]; then
		case $special in
		remove)
			if [ -f /etc/debian_version ]; then
				# Debian system
				COMPREPLY=( $( _comp-dpkg-installed-packages \
						$cur ) )
			else
				# assume RPM based
				_rpm_installed_packages
			fi
			return 0
			;;
		*)
			COMPREPLY=( $( apt-cache pkgnames $cur 2> /dev/null ) )
			return 0
			;;

		esac
	fi

	case "$prev" in
	    -@(c|-config-file))
 		     _filedir
		     return 0
		     ;;

	    -@(t|-target-release|-default-release))
		     COMPREPLY=( $( apt-cache policy | \
				    grep "release.o=Debian,a=$cur" | \
				    sed -e "s/.*a=\(\w*\).*/\1/" | uniq ) )
		     return 0
		     ;;
 
	esac

	if [[ "$cur" == -* ]]; then

		COMPREPLY=( $( compgen -W '-d -f -h -v -m -q -s -y \
				-u -t -b -c -o --download-only --fix-broken \
				--help --version --ignore-missing \
				--fix-missing --no-download --quiet --simulate \
				--just-print --dry-run --recon --no-act --yes \
				--assume-yes --show-upgraded --only-source \
				--compile --build --ignore-hold \
				--target-release --no-upgrade --force-yes \
				--print-uris --purge --reinstall \
				--list-cleanup --default-release \
				--trivial-only --no-remove --diff-only \
				--tar-only --config-file --option' -- $cur ) )
	else

		COMPREPLY=( $( compgen -W 'update upgrade dselect-upgrade \
				dist-upgrade install remove source build-dep \
				check clean autoclean' -- $cur ) )

	fi


	return 0
}
[ -n "${have:-}" ] && complete -F _apt_get $filenames apt-get

# Debian apt-cache(8) completion.
#
have apt-cache &&
_apt_cache()
{
	local cur prev special i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	
	if [ "$cur" != show ]; then
	    for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
		if [[ ${COMP_WORDS[i]} == @(add|depends|dotty|policy|rdepends|show?(pkg|src)) ]]; then
		    special=${COMP_WORDS[i]}
		fi
	    done
	fi


	if [ -n "$special" ]; then
	    case $special in
		add)
		    _filedir
		    return 0
		    ;;
		
 		*)
		    COMPREPLY=( $( apt-cache pkgnames $cur 2> /dev/null ) )
		    return 0
		    ;;
		
	    esac
	fi


	case "$prev" in
	     -@(c|p|s|-config-file|-@(pkg|src)-cache))
		     _filedir
		     return 0
		     ;;
	     search)
		     if [[ "$cur" != -* ]]; then
			    return 0
		     fi
		     ;;
	esac

	if [[ "$cur" == -* ]]; then

		COMPREPLY=( $( compgen -W '-h -v -p -s -q -i -f -a -g -c \
				-o --help --version --pkg-cache --src-cache \
				--quiet --important --full --all-versions \
				--no-all-versions --generate --no-generate \
				--names-only --all-names --recurse \
				--config-file --option' -- $cur ) )
	else

		COMPREPLY=( $( compgen -W 'add gencaches showpkg showsrc \
				stats dump dumpavail unmet search search \
				depends rdepends pkgnames dotty xvcg \
				policy' -- $cur ) )

	fi


	return 0
}
[ -n "${have:-}" ] && complete -F _apt_cache $filenames apt-cache


# Debian aptitude(1) completion
#
have aptitude && {
_comp_dpkg_hold_packages()
{
	grep -B 2 'hold' /var/lib/dpkg/status | grep "Package: $1" \
		| cut -d\  -f2
}

_aptitude()
{
	local cur dashoptions prev special i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}


	dashoptions='-S -u -i -h --help --version -s --simulate -d \
		     --download-only -P --prompt -y --assume-yes -F \
		     --display-format -w --width -f --with-recommends \
		     --with-suggests --without-recommends --without-suggests'

	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
	    if [[ ${COMP_WORDS[i]} == @(install|hold|unhold|markauto|unmarkauto|dist-upgrade|download|purge|remove) ]]; then
		special=${COMP_WORDS[i]}
	    fi
	    #exclude some mutually exclusive options
	    [[ ${COMP_WORDS[i]} == '-u' ]] && dashoptions=${dashoptions/-i}
	    [[ ${COMP_WORDS[i]} == '-i' ]] && dashoptions=${dashoptions/-u}
	done

	if [[ -n "$special" ]]; then
	   case $special in
	       @(install|hold|markauto|unmarkauto|dist-upgrade|download))
		   COMPREPLY=( $( apt-cache pkgnames $cur 2> /dev/null ) )
		   return 0
		   ;;
	       @(purge|remove))
  		   COMPREPLY=( $( _comp-dpkg-installed-packages $cur ) )
		   return 0
		   ;;
	       unhold)
  		   COMPREPLY=( $( _comp_dpkg_hold_packages $cur ) )
		   return 0
		   ;;

	   esac
	fi

	case $prev in
	    # don't complete anything if these options are found
	    @(autoclean|clean|forget-new|search|upgrade|update))
		return 0
		;;
	    -S)
		_filedir
		return 0
		;;
	esac

	if [[ "$cur" == -* ]]; then
	    COMPREPLY=( $( compgen -W "$dashoptions" -- $cur ) )
	else
	    COMPREPLY=( $( compgen -W 'update upgrade forget-new clean \
				       autoclean install remove hold unhold \
				       purge markauto unmarkauto dist-upgrade \
				       download search' -- $cur ) )
	fi


	return 0
}
[ -n "${have:-}" ] && complete -F _aptitude $default aptitude
}

# Debian apt-build(1) completion.
#
have apt-build &&
_apt_build()
{
	local cur prev special i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
		if [[ ${COMP_WORDS[i]} == @(install|remove|source|info|clean) ]]; then
			special=${COMP_WORDS[i]}
		fi
	done

	if [ -n "$special" ]; then
		case $special in
		@(install|source|info))
			COMPREPLY=( $( apt-cache pkgnames $cur 2> /dev/null ) )
			return 0
			;;
		remove)
			COMPREPLY=( $( _comp-dpkg-installed-packages \
					$cur ) )
			return 0
			;;
		*)
			return 0
			;;
		esac
	fi

	case "$prev" in

	     --@(patch|build-dir|repository-dir))
		   _filedir
		   return 0
		   ;;
 
	     -@(h|-help))
		   return 0
		   ;;

	esac

	if [[ "$cur" == -* ]]; then
	    COMPREPLY=( $( compgen -W '--help --show-upgraded -u --build-dir \
				  --repository-dir --build-only \
				  --build-command --reinstall --rebuild \
				  --remove-builddep --no-wrapper --purge \
				  --patch --patch-strip -p --yes -y \
				  --version -v --no-source' -- $cur ) )

	else
	    COMPREPLY=( $( compgen -W 'update upgrade install remove \
				  source dist-upgrade world clean info \
				  clean-build update-repository ' -- $cur ) )
	fi


	return 0
}
[ -n "${have:-}" ] && complete -F _apt_build $filenames apt-build

# chsh(1) completion
#
_chsh()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [ "$prev" = "-s" ]; then
	  if [ -f /etc/debian_version ]; then
	    COMPREPLY=( $( </etc/shells ) )
	  else
	    COMPREPLY=( $( chsh -l | grep "^$cur" ) )
	  fi
	else
	  COMPREPLY=( $( compgen -u -- $cur ) )
	fi

	return 0
}
complete -F _chsh chsh

# chkconfig(8) completion
#
have chkconfig &&
_chkconfig()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -W '--list --add --del --level' -- \
			       $cur ) )
		return 0
	fi

	if [ $COMP_CWORD -eq 4 ]; then
		COMPREPLY=( $( compgen -W 'on off reset' -- $cur ) )
		return 0
	fi

	case "$prev" in
	@([1-6]|--@(list|add|del)))
		COMPREPLY=( $( compgen -W "`(cd /etc/rc.d/init.d; echo *)`" \
			       -- $cur) )
		return 0
		;;
	--level)
		COMPREPLY=( $( compgen -W '1 2 3 4 5 6' -- $cur ) )
		return 0
		;;
	esac

	return 0
}
[ -n "${have:-}" ] && complete -F _chkconfig chkconfig

# This function provides simple user@host completion
#
_user_at_host() {
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [[ $cur == *@* ]]; then
		_known_hosts
	else
		COMPREPLY=( $( compgen -S '@' -u -- "$cur" ) )
	fi

	return 0
}
shopt -u hostcomplete && complete -F _user_at_host $nospace talk ytalk finger

# This function performs host completion based on ssh's known_hosts files,
# defaulting to standard host completion if they don't exist.
#
_known_hosts()
{
	local cur ocur user suffix aliases global_kh user_kh hosts
	local -a kh config

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	ocur=$cur

	[ "$1" = -a ] || [ "$2" = -a ] && aliases='yes'
	[ "$1" = -c ] || [ "$2" = -c ] && suffix=':'
	[[ $cur == *@* ]] && user=${cur%@*}@ && cur=${cur#*@}
	kh=()

	# ssh config files
	[ -r /etc/ssh/ssh_config ] && config[0]=/etc/ssh/ssh_config
	[ -r ~/.ssh/config ]	   && config[1]=~/.ssh/config

	if [ ${#config[@]} -gt 0 ]; then
	    # expand path (if present) to global known hosts file
	    global_kh=$( eval echo $( sed -ne 's/^[Gg][Ll][Oo][Bb][Aa][Ll][Kk][Nn][Oo][Ww][Nn][Hh][Oo][Ss][Tt][Ss][Ff][Ii][Ll][Ee]['$'\t '']*\(.*\)$/\1/p' ${config[@]} ) )
	    # expand path (if present) to user known hosts file
	    user_kh=$( eval echo $( sed -ne 's/^[Uu][Ss][Ee][Rr][Kk][Nn][Oo][Ww][Nn][Hh][Oo][Ss][Tt][Ss][Ff][Ii][Ll][Ee]['$'\t '']*\(.*\)$/\1/p' ${config[@]} ) )
	fi

	# choose which global known hosts file to use
	if [ -r "$global_kh" ]; then
	    kh=( "$global_kh" )
	else
	    [ -r /etc/ssh/ssh_known_hosts ]  && kh[0]=/etc/ssh/ssh_known_hosts
	    [ -r /etc/ssh/ssh_known_hosts2 ] && kh[1]=/etc/ssh/ssh_known_hosts2
	    [ -r /etc/known_hosts ]	     && kh[2]=/etc/known_hosts
	    [ -r /etc/known_hosts2 ]	     && kh[3]=/etc/known_hosts2
	fi

	# choose which user known hosts file to use
	if [ -r "$user_kh" ]; then
	    kh=( ${kh[@]} "$user_kh" )
	else
	    [ -r ~/.ssh/known_hosts ]  && kh=( ${kh[@]} ~/.ssh/known_hosts )
	    [ -r ~/.ssh/known_hosts2 ] && kh=( ${kh[@]} ~/.ssh/known_hosts2 )
	fi

	# If we have known_hosts files to use
	if [ ${#kh[@]} -gt 0 ]; then
	    # Escape slashes and dots in paths for awk
	    cur=${cur//\//\\\/}
	    cur=${cur//\./\\\.}

	    if [[ "$cur" == [0-9]*.* ]]; then
		# Digits followed by a dot - just search for that
		cur="^$cur.*"
	    elif [[ "$cur" == [0-9]* ]]; then
		# Digits followed by no dot - search for digits followed
		# by a dot
		cur="^$cur.*\."
	    elif [ -z "$cur" ]; then
		# A blank - search for a dot or an alpha character
		cur="[a-z.]"
	    else
		cur="^$cur"
	    fi

	    # FS needs to look for a comma separated list
	    COMPREPLY=( $( awk 'BEGIN {FS=","}
				{for (i=1; i<=2; ++i) { \
				       gsub(" .*$", "", $i); \
				       if ($i ~ /'$cur'/) {print $i} \
				}}' ${kh[@]} 2>/dev/null ) )

	    # append any available aliases from config files
	    if [ ${#config[@]} -gt 0 ] && [ -n "$aliases" ]; then
		hosts=$( compgen -W "$( echo $( sed -ne "s/^[Hh][Oo][Ss][Tt]["$'\t '"]*\([^*?]*\)$/\1/p" ${config[@]} ) )" -- $ocur )
		COMPREPLY=( ${COMPREPLY[@]} $hosts )
	    fi

	    # apply suffix
	    for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
		COMPREPLY[i]=$user${COMPREPLY[i]}$suffix
	    done
	else
	    # Just do normal hostname completion
	    COMPREPLY=( $( compgen -A hostname -S "$suffix" -- $cur ) )
	fi

	return 0
}
complete -F _known_hosts traceroute traceroute6 tracepath tracepath6 \
	ping fping telnet host nslookup rsh rlogin ftp dig

# ssh(1) completion
#
have ssh && {
_ssh()
{
	local cur prev
	local -a config

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-*c)
	    COMPREPLY=( $( compgen -W 'blowfish 3des 3des-cbc blowfish-cbc \
			   arcfour cast128-cbc' -- $cur ) )
	    ;;
	-*i)
	    _filedir
	    ;;
	-*l)
	    COMPREPLY=( $( compgen -u -- $cur ) )
	    ;;
	*)
	    _known_hosts -a

	    [ $COMP_CWORD -eq 1 ] || \
		COMPREPLY=( ${COMPREPLY[@]} $( compgen -c -- $cur ) )
	esac

	return 0
}
shopt -u hostcomplete && complete -F _ssh ssh slogin sftp xhost

# scp(1) completion
#
_scp()
{
	local cur userhost path

	local IFS=$'\t\n'
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_expand || return 0

	if [[ "$cur" == *:* ]]; then
		# remove backslash escape from :
		cur=${cur/\\:/:}
		userhost=${cur%%?(\\):*}
		path=${cur#*:}
		# unescape spaces
		path=${path//\\\\\\\\ / }
		if [ -z "$path" ]; then
			# default to home dir of specified user on remote host
			path=$(ssh -o 'Batchmode yes' $userhost pwd 2>/dev/null)
		fi
		# escape spaces; remove executables, aliases, pipes and sockets;
		# add space at end of file names
		COMPREPLY=( $( ssh -o 'Batchmode yes' $userhost \
				command ls -aF1d "$path*" 2>/dev/null | \
				sed -e 's/ /\\\\\\\ /g' -e 's/[*@|=]$//g' \
				    -e 's/[^\/]$/& /g' ) )
		return 0
	fi

	[[ "$cur" == */* ]] || _known_hosts -c -a
		COMPREPLY=( ${COMPREPLY[@]} $( command ls -aF1d $cur* \
			    2>/dev/null | sed -e 's/ /\\ /g' -e 's/[*@|=]$//g'\
			    -e 's/[^\/]$/& /g' ) )



	return 0
}
complete -F _scp $nospace scp
}

# rsync(1) completion
#
have rsync &&
_rsync()
{
	local cur prev shell i userhost path
 
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	_expand || return 0

	case "$prev" in
	--@(config|password-file|include-from|exclude-from))
		_filedir
		return 0
		;;
	-@(T|-temp-dir|-compare-dest))
		_filedir -d
		return 0
		;;
	-@(e|-rsh))
		COMPREPLY=( $( compgen -W 'rsh ssh' -- $cur ) )
		return 0
		;;
	esac
 
	case "$cur" in
	-*)
		COMPREPLY=( $( compgen -W '-v -q  -c -a -r -R -b -u -l -L -H \
				-p -o -g -D -t -S -n -W -x -B -e -C -I -T -P \
				-z -h -4 -6 --verbose --quiet --checksum \
				--archive --recursive --relative --backup \
				--backup-dir --suffix= --update --links \
				--copy-links --copy-unsafe-links --safe-links \
				--hard-links --perms --owner --group --devices\
				--times --sparse --dry-run --whole-file \
				--no-whole-file --one-file-system \
				--block-size= --rsh= --rsync-path= \
				--cvs-exclude --existing --ignore-existing \
				--delete --delete-excluded --delete-after \
				--ignore-errors --max-delete= --partial \
				--force --numeric-ids --timeout= \
				--ignore-times --size-only --modify-window= \
				--temp-dir= --compare-dest= --compress \
				--exclude= --exclude-from= --include= \
				--include-from= --version --daemon --no-detach\
				--address= --config= --port= --blocking-io \
				--no-blocking-io --stats --progress \
				--log-format= --password-file= --bwlimit= \
				--write-batch= --read-batch= --help' -- $cur ))
		;;
	*:*)
		# find which remote shell is used
		shell=rsh
		for (( i=1; i < COMP_CWORD; i++ )); do
			if [[ "${COMP_WORDS[i]}" == -@(e|-rsh) ]]; then
				shell=${COMP_WORDS[i+1]}
				break
			fi
		done
		if [[ "$shell" == ssh ]]; then
			# remove backslash escape from :
			cur=${cur/\\:/:}
			userhost=${cur%%?(\\):*}
			path=${cur#*:}
			# unescape spaces
			path=${path//\\\\\\\\ / }
			if [ -z "$path" ]; then
				# default to home dir of specified
				# user on remote host
				path=$(ssh -o 'Batchmode yes' \
					$userhost pwd 2>/dev/null)
			fi
			# escape spaces; remove executables, aliases, pipes
			# and sockets; add space at end of file names
			COMPREPLY=( $( ssh -o 'Batchmode yes' $userhost \
				command ls -aF1d "$path*" 2>/dev/null | \
				sed -e 's/ /\\\\\\\ /g' -e 's/[*@|=]$//g' \
				-e 's/[^\/]$/& /g' ) )
		fi
		;;
	*)
		_known_hosts -c -a
		_filedir
		;;
	esac
 
	return 0
}
[ -n "${have:-}" ] && complete -F _rsync $nospace rsync

# Linux route(8) completion
#
[ $UNAME = Linux ] &&
_route()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [ "$prev" = dev ]; then
	    COMPREPLY=( $( ifconfig -a | sed -ne 's|^\('$cur'[^ ]*\).*$|\1|p' ))
	    return 0
	fi

	COMPREPLY=( $( compgen -W 'add del -host -net netmask metric mss \
				   window irtt reject mod dyn reinstate dev \
				   default gw' -- $cur ) )

	COMPREPLY=( $( echo " ${COMP_WORDS[@]}" | \
		       (while read -d ' ' i; do
			   [ "$i" == "" ] && continue
			   # flatten array with spaces on either side,
			   # otherwise we cannot grep on word
			   # boundaries of first and last word
			   COMPREPLY=" ${COMPREPLY[@]} "
			   # remove word from list of completions
			   COMPREPLY=( ${COMPREPLY/ $i / } )
			done
		       echo ${COMPREPLY[@]})
		  ) )
	return 0
}
[ $UNAME = Linux ] && complete -F _route route

# GNU make(1) completion (adapted from the example supplied with the bash 2.04
# source code)
#
have make &&
_make()
{
	local makef cur prev i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	# --name value style option
	case $prev in
		-@(f|o|W))
			_filedir
			return 0
			;;
		-@(I|C))
			_filedir -d
			return 0
			;;
	esac

	# --name=value style option
	if [[ "$cur" == *=* ]]; then
		prev=${cur/=*/}
		cur=${cur/*=/}
		case "$prev" in
			--@(file|makefile))
				_filedir
				return 0
				;;
			--@(directory|include-dir))
				_filedir -d
				return 0
				;;
		esac
	fi

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-b -m -B -C -d -e -f -h -i -I\
			-j -l -k -n -o -p -q -r -R - s -S -t -v -w -W \
			--always-make --directory= --debug \
			--environment-overrides --file= --makefile= --help \
			--ignore-errors --include-dir= --jobs --load-average \
			--max-load --keep-going --just-print --dry-run \
			--recon --old-file= --assume-old= --print-data-base \
			--question --no-builtin-rules --no-builtin-variables \
			--silent --quiet --no-keep-goind --stop --touch \
			--version --print-directory --no-print-directory \
			--what-if= --new-file= --assume-new= \
			--warn-undefined-variables' -- $cur ) )
	else
		# make reads `GNUmakefile', then `makefile', then `Makefile'
		if [ -f GNUmakefile ]; then
			makef=GNUmakefile
		elif [ -f makefile ]; then
			makef=makefile
		elif [ -f Makefile ]; then
			makef=Makefile
		else
			makef=*.mk	       # local convention
		fi

		# before we scan for targets, see if a makefile name was specified
		# with -f
		for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
			if [[ ${COMP_WORDS[i]} == -f ]]; then
				# eval for tilde expansion
				eval makef=${COMP_WORDS[i+1]}
				break
			fi
		done

		[ ! -f $makef ] && return 0

		COMPREPLY=( $( awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ \
				{split($1,A,/ /);for(i in A)print A[i]}' \
				$makef 2>/dev/null | grep "^$cur" ))
	fi
}
[ -n "${have:-}" ] && complete -F _make $filenames make gmake pmake

# GNU tar(1) completion
#
_tar()
{
	local cur ext regex tar untar

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -W 'c t x u r d A' -- $cur ) )
		return 0
	fi

	case "${COMP_WORDS[1]}" in
	?(-)c*f)
		_filedir
		return 0
		;;
	+([^Izjy])f)
		ext='tar'
		regex=$ext
		;;
	*z*f)
		ext='t?(ar.)@(gz|Z)'
		regex='t\(ar\.\)\(gz\|Z\)'
		;;
	*[Ijy]*f)
		ext='t?(ar.)bz?(2)'
		regex='t\(ar\.\)bz2\?'
		;;
	*)
		_filedir
		return 0
		;;
		
	esac

	if [[ "$COMP_LINE" == *$ext' ' ]]; then
		# complete on files in tar file
		#
		# get name of tar file from command line
		tar=$( echo "$COMP_LINE" | \
			sed -e 's|^.* \([^ ]*'$regex'\) .*$|\1|' )
		# devise how to untar and list it
		untar=t${COMP_WORDS[1]//[^Izjyf]/}

		COMPREPLY=( $( compgen -W "$( echo $( tar $untar $tar \
				2>/dev/null ) )" -- "$cur" ) )
		return 0
	fi

	# file completion on relevant files
	_filedir $ext

	return 0
}
[ -n "${COMP_TAR_INTERNAL_PATHS:-}" ] && complete -F _tar $dirnames tar ||
	complete -F _tar $filenames tar

# jar(1) completion
#
have jar &&
_jar()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD = 1 ]; then
		COMPREPLY=( $( compgen -W 'c t x u' -- $cur ) )
		return 0
	fi

	case "${COMP_WORDS[1]}" in
		*c*f)
			_filedir
			;;
		*f)
			_filedir '?(e|j|w)ar'
			;;
		*)
			_filedir
			;;
	esac
}
[ -n "${have:-}" ] && complete -F _jar $filenames jar

# Linux iptables(8) completion
#
have iptables &&
_iptables()
{
	local cur prev table chain

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]} 
	prev=${COMP_WORDS[COMP_CWORD-1]}
	chain='s/^Chain \([^ ]\+\).*$/\1/p'

	if [[ $COMP_LINE == *-t\ *filter* ]]; then
		table="-t filter"
	elif [[ $COMP_LINE == *-t\ *nat* ]]; then
		table="-t nat"
	elif [[ $COMP_LINE == *-t\ *mangle* ]]; then
		table="-t mangle"
	fi

	case "$prev" in
	-*[AIDRPFXLZ])
		COMPREPLY=( $( compgen -W '`iptables $table -nL | \
			    sed -ne "s/^Chain \([^ ]\+\).*$/\1/p"`' -- $cur ) )
		;;
	-*t)
		COMPREPLY=( $( compgen -W 'nat filter mangle' -- $cur ) )
		;;
	-j)
		if [ "$table" = "-t filter" -o "$table" = "" ]; then
		    COMPREPLY=( $( compgen -W 'ACCEPT DROP LOG ULOG REJECT \
		    `iptables $table -nL | sed -ne "$chain" \
		    -e "s/INPUT|OUTPUT|FORWARD|PREROUTING|POSTROUTING//"`' -- \
		    $cur ) )
		elif [ "$table" = "-t nat" ]; then
		    COMPREPLY=( $( compgen -W 'ACCEPT DROP LOG ULOG REJECT \
		    MIRROR SNAT DNAT MASQUERADE `iptables $table -nL | \
		    sed -ne "$chain" -e "s/OUTPUT|PREROUTING|POSTROUTING//"`' \
		    -- $cur ) )
		elif [ "$table" = "-t mangle" ]; then
		    COMPREPLY=( $( compgen -W 'ACCEPT DROP LOG ULOG REJECT \
		    MARK TOS `iptables $table -nL | sed -ne "$chain" \
		    -e "s/INPUT|OUTPUT|FORWARD|PREROUTING|POSTROUTING//"`' -- \
		    $cur ) )
		fi
		;;
	*)
		if [[ "$cur" == -* ]]; then
		    COMPREPLY=( $( compgen -W '-i -o -s -d -p -f -m --append \
		    --delete --insert --replace --list --flush --zero --new \
		    --delete-chain --policy --rename-chain --proto --source \
		    --destination --in-interface --jump --match --numeric \
		    --out-interface --table --verbose --line-numbers --exact \
		    --fragment --modprobe= --set-counters --version' -- "$cur") )
		fi
		;;
	esac

} 
[ -n "${have:-}" ] && complete -F _iptables iptables

# tcpdump(8) completion
#
have tcpdump &&
_tcpdump()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
		-@(r|w|F))
			_filedir
			return 0
			;;
		-i)
			_interfaces
			return 0
			;;
	esac


	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-a -d -e -f -l -n -N -O -p \
			-q -R -S -t -u -v -x -C -F -i -m -r -s -T -w \
			-E' -- $cur ) )
	fi

}
[ -n "${have:-}" ] && complete -F _tcpdump tcpdump

# autorpm(8) completion
#
have autorpm &&
_autorpm()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=( $( compgen -W '--notty --debug --help --version \
				   auto add fullinfo info help install list \
				   remove set' -- $cur ) )

}
[ -n "${have:-}" ] && complete -F _autorpm autorpm

# This meta-cd function observes the CDPATH variable, so that cd additionally
# completes on directories under those specified in CDPATH.
#
_cd()
{
	local IFS=$'\t\n' cur=${COMP_WORDS[COMP_CWORD]} i j k

	# try to allow variable completion
	if [[ "$cur" == ?(\\)\$* ]]; then
		COMPREPLY=( $( compgen -v -P '$' -- "${cur#?(\\)$}" ) )
		return 0
	fi

	# Use standard dir completion if no CDPATH or parameter starts with /,
	# ./ or ../
	if [ -z "${CDPATH:-}" ] || [[ "$cur" == ?(.)?(.)/* ]]; then
		_filedir -d
		return 0
	fi

	IFS=$'\t\n'
	# we have a CDPATH, so loop on its contents
	for i in ${CDPATH//:/$'\t'}; do
		# create an array of matched subdirs
		k=${#COMPREPLY[@]}
		for j in $( compgen -d $i/$cur ); do
			COMPREPLY[$k]=${j#$i/}
			k=$((++k))
		done
	done

	_filedir -d

	return 0
}
if shopt -q cdable_vars; then
    complete -v -F _cd $nospace $filenames cd
else
    complete -F _cd $nospace $filenames cd
fi

# A meta-command completion function for commands like sudo(8), which need to
# first complete on a command, then complete according to that command's own
# completion definition - currently not quite foolproof (e.g. mount and umount
# don't work properly), but still quite useful
#
_command()
{
	local cur func cline cspec noglob cmd \
	      _COMMAND_FUNC _COMMAND_FUNC_ARGS

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	cmd=${COMP_WORDS[1]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -c -- $cur ) )
	elif complete -p $cmd &>/dev/null; then
		cspec=$( complete -p $cmd )
		if [ "${cspec#* -F }" != "$cspec" ]; then
			# complete -F <function>
			#
			# COMP_CWORD and COMP_WORDS() are not read-only,
			# so we can set them before handing off to regular
			# completion routine

			# set current token number to 1 less than now
			COMP_CWORD=$(( $COMP_CWORD - 1 ))
			# get function name
			func=${cspec#*-F }
			func=${func%% *}
			# get current command line minus initial command
			cline="${COMP_LINE#$1 }"
			# save noglob state
		      	shopt -o noglob >/dev/null; noglob=$?
			# turn on noglob, as things like 'sudo ls *<Tab>'
			# don't work otherwise
		  	shopt -so noglob
			# split current command line tokens into array
			COMP_WORDS=( $cline )
			# reset noglob if necessary
			[ $noglob -eq 1 ] && shopt -uo noglob
			$func $cline
			# this is needed in case user finished entering command and pressed tab (e.g. sudo ls <Tab>)
			COMP_CWORD=$(( $COMP_CWORD > 0 ? $COMP_CWORD : 1 ))
			cur=${COMP_WORDS[COMP_CWORD]}
			_COMMAND_FUNC=$func
			_COMMAND_FUNC_ARGS=( $cmd $2 $3 )
			COMP_LINE=$cline
			COMP_POINT=$(( ${COMP_POINT} - ${#1} - 1 ))
			$func $cmd $2 $3
			# remove any \: generated by a command that doesn't
			# default to filenames or dirnames (e.g. sudo chown)
			if [ "${cspec#*-o }" != "$cspec" ]; then
				cspec=${cspec#*-o }
				cspec=${cspec%% *}
				if [[ "$cspec" != @(dir|file)names ]]; then
					COMPREPLY=("${COMPREPLY[@]//\\\\:/:}")
				fi
			fi
		elif [ -n "$cspec" ]; then
			cspec=${cspec#complete};
			cspec=${cspec%%$cmd};
			COMPREPLY=( $( eval compgen "$cspec" -- "$cur" ) );
		fi
	fi

	[ ${#COMPREPLY[@]} -eq 0 ] && _filedir
}
complete -F _command $filenames nohup exec nice eval strace time ltrace then \
	 else do vsound command

_root_command()
{
	PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin _command $1 $2 $3
}
complete -F _root_command $filenames sudo fakeroot really

# ant(1) completion
#
have ant &&
_ant()
{
	local cur prev buildfile i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
		-buildfile|-f)
			_filedir 'xml'
			return 0
			;;
		-logfile)
			_filedir
			return 0
			;;
	esac

	if [[ "$cur" == -* ]]; then
		# relevant options completion
		COMPREPLY=( $( compgen -W '-help -projecthelp -version -quiet \
			       -verbose -debug -emacs -logfile -logger \
			       -listener -buildfile -f -D -find' -- $cur ) )
	else
		# available targets completion
		# find which buildfile to use
		buildfile=build.xml
		for (( i=1; i < COMP_CWORD; i++ )); do
			if [[ "${COMP_WORDS[i]}" == -buildfile ]]; then
				buildfile=${COMP_WORDS[i+1]}
				break
			fi
		done
		[ ! -f $buildfile ] && return 0

		# parse buildfile for targets
		COMPREPLY=( $( awk -F'"' '/<target name="/ {print $2}' \
				$buildfile | grep "^$cur" )
			    $( awk -F"'" "/<target name='/ "'{print $2}' \
				$buildfile | grep "^$cur" )
			    $( awk -F'"' '/<target [^n]/ {if ($1 ~ /name=/) { print $2 } else if ($3 ~ /name=/) {print $4} else if ($5 ~ /name=/) {print $6}}' \
				$buildfile | grep "^$cur" ) )
	fi
}
[ -n "${have:-}" ] && complete -F _ant $filenames ant

have nslookup &&
_nslookup()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]#-}

	COMPREPLY=( $( compgen -P '-' -W 'all class= debug d2 domain= \
			       srchlist= defname search port= querytype= \
			       type= recurse retry root timeout vc \
			       ignoretc' -- $cur ) )
}
[ -n "${have:-}" ] && complete -F _nslookup nslookup

# mysqladmin(1) completion
#
have mysqladmin &&
_mysqladmin()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]} 
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-u)
		COMPREPLY=( $( compgen -u -- $cur ) )
		return 0
		;;
	*)
		;;
	esac

	COMPREPLY=( $( compgen -W '-# -f -? -C -h -p -P -i -r -E -s -S -t -u \
					      -v -V -w' -- $cur ) )

	COMPREPLY=( ${COMPREPLY[@]} \
		    $( compgen -W 'create drop extended-status flush-hosts \
				   flush-logs flush-status flush-tables \
				   flush-threads flush-privileges kill \
				   password ping processlist reload refresh \
				   shutdown status variables version' \
		       -- $cur ) )
}
[ -n "${have:-}" ] && complete -F _mysqladmin mysqladmin

# gzip(1) completion
#
have gzip &&
_gzip()
{
	local cur prev xspec

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-c -d -f \
			-h -l -L -n -N -q -r -S -t -v -V \
			-1 -2 -3 -4 -5 -6 -7 -8 -9 \
			--stdout --decompress --force --help --list \
			--license --no-name --name --quiet --recursive \
			--suffix --test --verbose --version --fast \
			--best' -- $cur ) )
		return 0
	fi

	xspec="*.?(t)gz"
	if [[ "$prev" == --* ]]; then
		[[ "$prev" == --decompress || \
			"$prev" == --list || \
			"$prev" == --test ]] && xspec="!"$xspec
		[[ "$prev" == --force ]] && xspec=
	elif [[ "$prev" == -* ]]; then
		[[ "$prev" == -*[dlt]* ]] && xspec="!"$xspec
		[[ "$prev" == -*f* ]] && xspec=
	elif [ "$prev" = '>' ]; then
		xspec=
	fi

	_expand || return 0

	COMPREPLY=( $( compgen -f -X "$xspec" -- $cur ) \
		    $( compgen -d -- $cur ) )
}
[ -n "${have:-}" ] && complete -F _gzip $filenames gzip

# bzip2(1) completion
#
have bzip2 &&
_bzip2()
{
	local cur prev xspec

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-c -d -f -h -k -L -q -s \
			-t -v -V -z -1 -2 -3 -4 -5 -6 -7 -8 -9 \
			--help --decompress --compress --keep --force \
			--test --stdout --quiet --verbose --license \
			--version --small --fast --best' -- $cur ) )
		return 0
	fi

	xspec="*.bz2"
	if [[ "$prev" == --* ]]; then
		[[ "$prev" == --decompress || \
			"$prev" == --list || \
			"$prev" == --test ]] && xspec="!"$xspec
		[[ "$prev" == --compress ]] && xspec=
	elif [[ "$prev" == -* ]]; then
		[[ "$prev" == -*[dt]* ]] && xspec="!"$xspec
		[[ "$prev" == -*z* ]] && xspec=
	fi

	_expand || return 0

	COMPREPLY=( $( compgen -f -X "$xspec" -- $cur ) \
		    $( compgen -d -- $cur ) )
}
[ -n "${have:-}" ] && complete -F _bzip2 $filenames bzip2

# openssl(1) completion
#
have openssl &&
_openssl()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -W 'asn1parse ca ciphers crl crl2pkcs7 \
			dgst dh dhparam dsa dsaparam enc errstr gendh gendsa \
			genrsa nseq passwd pkcs12 pkcs7 pkcs8 rand req rsa \
			rsautl s_client s_server s_time sess_id smime speed \
			spkac verify version x509 md2 md4 md5 mdc2 rmd160 sha \
			sha1 base64 bf bf-cbc bf-cfb bf-ecb bf-ofb cast \
			cast-cbc cast5-cbc cast5-cfb cast5-ecb cast5-ofb des \
			des-cbc des-cfb des-ecb des-ede des-ede-cbc \
			des-ede-cfb des-ede-ofb des-ede3 des-ede3-cbc \
			des-ede3-cfb des-ede3-ofb des-ofb des3 desx rc2 \
			rc2-40-cbc rc2-64-cbc rc2-cbc rc2-cfb rc2-ecb rc2-ofb \
			rc4 rc4-40' -- $cur ) )
	fi

	return 0
}
[ -n "${have:-}" ] && complete -F _openssl $default openssl

# screen(1) completion
#
have screen &&
_screen()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	test "$COMP_CWORD" -ge 2 && preprev=${COMP_WORDS[COMP_CWORD-2]} || unset preprev

	if test "$preprev" = "-d" -o "$preprev" = "-D" -a "$prev" = "-r" -o "$prev" = "-R"; then
		# list all
		COMPREPLY=( $( command screen -ls | \
				sed -ne 's|^['$'\t'']\+[0-9]\+\.\('$cur'[^'$'\t'']\+\).*$|\1|p' ) )
	else
		case "$prev" in
		-[rR])
			# list detached
			COMPREPLY=( $( command screen -ls | \
					sed -ne 's|^['$'\t'']\+[0-9]\+\.\('$cur'[^'$'\t'']\+\).*Detached.*$|\1|p' ) )
			;;
		-[dDx])
			# list attached
			COMPREPLY=( $( command screen -ls | \
					sed -ne 's|^['$'\t'']\+[0-9]\+\.\('$cur'[^'$'\t'']\+\).*Attached.*$|\1|p' ) )
			;;
		-s)
			# shells
			COMPREPLY=( $( grep ^${cur:-[^#]} /etc/shells ) )
			;;
		*)
			;;
		esac
	fi

	return 0
}
[ -n "${have:-}" ] && complete -F _screen $default screen

# lftp(1) bookmark completion
#
have lftp &&
_lftp()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ] && [ -f ~/.lftp/bookmarks ]; then
	    COMPREPLY=( $( compgen -W '$( sed -ne "s/^\(.*\)'$'\t''.*$/\1/p" \
			   ~/.lftp/bookmarks )' -- $cur ) )
	fi

	return 0
}
[ -n "${have:-}" ] && complete -F _lftp $default lftp

# ncftp(1) bookmark completion
#
have ncftp &&
_ncftp()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ] && [ -f ~/.ncftp/bookmarks ]; then
	    COMPREPLY=( $( compgen -W '$( sed -ne "s/^\([^,]\{1,\}\),.*$/\1/p" \
			   ~/.ncftp/bookmarks )' -- $cur ) )
	fi

	return 0
}
[ -n "${have:-}" ] && complete -F _ncftp $default ncftp

# gdb(1) completion
#
have gdb &&
_gdb()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -c -- $cur ) )
	elif [ $COMP_CWORD -eq 2 ]; then
		prev=${prev##*/}
		COMPREPLY=( $( compgen -W "$( compgen -f core \
				$( command ps axo comm,pid |
				awk '{if ($1 ~ /^'$prev'/) print $2}' ) )" \
				-- "$cur" ) )
	fi
}
[ -n "${have:-}" ] && complete -F _gdb $filenames gdb

# Postgresql completion
#
have psql && {
_pg_databases() 
{
	COMPREPLY=( $( psql -l 2>/dev/null | \
			sed -e '1,/^-/d' -e '/^(/,$d' | \
			awk '{print $1}' | grep "^$cur" ) )
}

_pg_users()
{
	COMPREPLY=( $( psql -qtc 'select usename from pg_user' template1 2>/dev/null | \
			grep "^ $cur" ) )
	[ ${#COMPREPLY[@]} -eq 0 ] && COMPREPLY=( $( compgen -u -- $cur ) )
}

# psql(1) completion
#
_psql() 
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-h|--host) 
		_known_hosts
		return 0
		;;
	-U|--username)
		_pg_users
		return 0
		;;
	-d|--dbname)
		_pg_databases
		return 0
		;;
	-@(o|f)|--output|--file)
		_filedir
		return 0
		;;
	esac

	if [[ "$cur" == -* ]]; then
		# return list of available options
		COMPREPLY=( $( compgen -W '-a --echo-all -A --no-align \
			-c --command -d --dbname -e --echo-queries \
			-E --echo-hidden -f --file -F --filed-separator \
			-h --host -H --html -l --list -n -o --output \
			-p --port -P --pset -q -R --record-separator \
			-s --single-step -S --single-line -t --tuples-only \
			-T --table-attr -U --username -v --variable \
			-V --version -W --password -x --expanded -X --nopsqlrc \
			-? --help ' -- $cur ) )
	else
		# return list of available databases
		_pg_databases
	fi
}
complete -F _psql $default psql

# createdb(1) completion
#
_createdb() 
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-@(h|-host=)) 
		_known_hosts
		return 0
		;;
	-@(U|-username=))
		_pg_users
		return 0
		;;
	esac

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-D -T -E -h -p -U -W -e -q \
			--location= --template= --encoding= --host= --port= \
			--username= --password --echo --quiet --help' -- $cur ))
	else
		_pg_databases
	fi
}
complete -F _createdb $default createdb

# dropdb(1) completion
#
_dropdb() 
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-@(h|-host=)) 
		_known_hosts
		return 0
		;;
	-@(U|-username=))
		_pg_users
		return 0
		;;
	esac

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-h -p -U -W -e -q \
				--host= --port= --username= --password \
				--interactive --echo --quiet --help' -- $cur ) )
	else
		_pg_databases
	fi
}
complete -F _dropdb $default dropdb
}

_longopt()
{
	local cur opt

	cur=${COMP_WORDS[COMP_CWORD]}

	if [[ "$cur" == --*=* ]]; then
		opt=${cur%%=*}
		# cut backslash that gets inserted before '=' sign
		opt=${opt%\\*}
		cur=${cur#*=}
		_filedir
		COMPREPLY=( $( compgen -P "$opt=" -W '${COMPREPLY[@]}' -- $cur))
		return 0
	fi

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( $1 --help 2>&1 | sed -e '/--/!d' \
				-e 's/.*\(--[-A-Za-z0-9]\+=\?\).*/\1/' | \
			       grep "^$cur" | sort -u ) )
	elif [[ "$1" == @(mk|rm)dir ]]; then
		_filedir -d
	else
		_filedir
	fi
}
# makeinfo and texi2dvi are defined elsewhere
for i in a2ps autoconf automake bc gprof ld nm objcopy objdump readelf strip \
	 bison cpio diff patch enscript cp df dir du ln ls mkfifo mknod mv rm \
	 touch vdir xargs awk gperf grep grub indent less m4 sed shar date \
	 env seq tee uname who texindex cat csplit cut expand fmt fold head \
	 md5sum nl od paste pr ptx sha1sum sort split tac tail tr unexpand \
	 uniq wc units wget ldd bash id info irb mkdir rmdir netstat; do
    have $i && complete -F _longopt $filenames $i
done
unset i

# gcc(1) completion
#
# The only unusual feature is that we don't parse "gcc --help -v" output
# directly, because that would include the options of all the other backend
# tools (linker, assembler, preprocessor, etc) without any indication that
# you cannot feed such options to the gcc driver directly.  (For example, the
# linker takes a -z option, but you must type -Wl,-z for gcc.)  Instead, we
# ask the driver ("g++") for the name of the compiler ("cc1"), and parse the
# --help output of the compiler.
#
have gcc &&
_gcc()
{
	local cur cc backend

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_expand || return 0

	case "$1" in
	gcj)
		backend=jc1
		;;
	gpc)
		backend=gpc1
		;;
	*77)
		backend=f771
		;;
	*)
		backend=cc1	# (near-)universal backend
		;;
	esac

	if [[ "$cur" == -* ]]; then
		cc=$( $1 -print-prog-name=$backend )
		# sink stderr:
		# for C/C++/ObjectiveC it's useless
		# for FORTRAN/Java it's an error
		COMPREPLY=( $( $cc --help 2>/dev/null | tr '\t' ' ' | \
			       sed -e '/^  *-/!d' -e 's/ *-\([^ ]*\).*/-\1/' | \
			       grep "^$cur" | sort -u ) )
	else
		_filedir
	fi
}
[ -n "${have:-}" ] && complete $filenames -F _gcc gcc g++ c++ g77 gcj gpc
[ $UNAME = GNU -o $UNAME = Linux -o $UNAME = Cygwin ] && \
complete $filenames -F _gcc cc

# Linux cardctl(8) completion
#
have cardctl &&
_cardctl()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -W 'status config ident suspend \
					   resume reset eject insert scheme' \
			       -- $cur ) )
	fi
}
[ -n "${have:-}" ] && complete -F _cardctl cardctl

# This function is required by _dpkg() and _dpkg-reconfigure()
#
have dpkg && {
_comp-dpkg-installed-packages()
{
	grep -A 2 "Package: $1" /var/lib/dpkg/status | \
		grep -B 2 'ok installed' | grep "Package: $1" | cut -d\  -f2
}

# Debian dpkg(8) completion
#
_dpkg()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	_expand || return 0

	# find the last option flag
	if [[ $cur != -* ]]; then
		while [[ $prev != -* && $COMP_CWORD != 1 ]]; do
		      COMP_CWORD=$((COMP_CWORD-1))
		      prev=${COMP_WORDS[COMP_CWORD-1]}
		done
	fi

	case "$prev" in 
	-@(c|i|A|I|f|e|x|X|-@(install|unpack|record-avail|contents|info| \
			  fsys-tarfile|field|control|extract)))
		_filedir '?(u)deb'
		return 0
		;;
	-@(b|-build))
		_filedir -d
		return 0
		;;
   	-@(s|p|l|-@(status|print-avail|list)))
		COMPREPLY=( $( apt-cache pkgnames $cur 2>/dev/null ) )
		return 0
		;;
	-@(S|-search))
		_filedir
		return 0
		;;
	-@(r|L|-@(remove|purge|listfiles)))
		COMPREPLY=( $( _comp-dpkg-installed-packages $cur ) )
		return 0
		;;
	*)

	COMPREPLY=( $( compgen -W '-i --install --unpack -A --record-avail \
			--configure -r --remove --purge --get-selections \
			--set-selections --update-avail --merge-avail \
			--clear-avail  --command-fd --forget-old-unavail -s \
			--status -p --print-avail -L --listfiles -l --list \
			-S --search -C --audit --print-architecture \
			--print-gnu-build-architecture \
			--print-installation-architecture \
			--compare-versions --help --version --force-help \
			--force-all --force-auto-select --force-downgrade \
			--force-configure-any --force-hold --force-bad-path \
			--force-not-root --force-overwrite \
			--force-overwrite-diverted --force-bad-verify \
			--force-depends-version --force-depends \
			--force-confnew --force-confold --force-confdef \
			--force-confmiss --force-conflicts --force-architecture\
			--force-overwrite-dir --force-remove-reinstreq \
			--force-remove-essential -Dh \
			--debug=help --licence --admindir= --root= --instdir= \
			-O --selected-only -E --skip-same-version \
			-G --refuse-downgrade -B --auto-deconfigure \
			--no-debsig --no-act -D --debug= --status-fd \
			-b --build -I --info -f --field -c --contents \
			-x --extract -X --vextract --fsys-tarfile -e --control \
			--ignore-depends= --abort-after' -- $cur ) )
		;;
	esac


}
complete -F _dpkg $filenames dpkg dpkg-deb
}

# Debian GNU dpkg-reconfigure(8) completion
#
have dpkg-reconfigure &&
_dpkg_reconfigure()
{
	local cur prev opt

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}


	case "$prev" in
	    -@(f|-frontend))
		opt=( $( echo /usr/share/perl5/Debconf/FrontEnd/* ) )
		opt=( ${opt[@]##*/} )
		opt=( ${opt[@]%.pm} )
		COMPREPLY=( $( compgen -W '${opt[@]}' -- $cur ) )
		return 0
		;;
	    -@(p|-priority))
  		COMPREPLY=( $( compgen -W 'low medium high critical' -- $cur ) )
		return 0
		;;
	esac

	if [[ "$cur" == -* ]]; then
	    COMPREPLY=( $( compgen -W '-f --frontend -p --priority -a --all \
				       -u --unseen-only -h --help -s --showold \
				       --force --terse' -- $cur ) )
	else
	    COMPREPLY=( $( _comp-dpkg-installed-packages $cur ) )
	fi
}
[ -n "${have:-}" ] && complete -F _dpkg_reconfigure $default dpkg-reconfigure

# Debian Linux dselect(8) completion.
#
have dselect &&
_dselect()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	     --admindir)
		  _filedir -d
		  return 0
		  ;;

	     -@(D|debug))
		  _filedir
		  return 0
		  ;;
	esac

	if [[ "$cur" == -* ]]; then
	    COMPREPLY=( $( compgen -W '--admindir --help --version --licence \
				  --license --expert --debug' -- $cur ) )
	else
	    COMPREPLY=( $( compgen -W 'access update select install config \
				  remove quit' -- $cur ) )
	fi


	return 0
}
[ -n "${have:-}" ] && complete -F _dselect $filenames dselect

# Java completion
#

# available path elements completion
have java && {
_java_path()
{
	cur=${cur##*:}
	_filedir '@(jar|zip)'
}

# exact classpath determination
_java_find_classpath()
{
	local i

	# search first in current options
	for (( i=1; i < COMP_CWORD; i++ )); do
		if [[ "${COMP_WORDS[i]}" == -@(cp|classpath) ]]; then
			classpath=${COMP_WORDS[i+1]}
			break
		fi
	done

	# default to environment
	[ -z "$classpath" ] && classpath=$CLASSPATH

	# default to current directory
	[ -z "$classpath" ] && classpath=.
}

# exact sourcepath determination
_java_find_sourcepath()
{
	local i

	# search first in current options
	for (( i=1; i < COMP_CWORD; i++ )); do
		if [[ "${COMP_WORDS[i]}" == -sourcepath ]]; then
			sourcepath=${COMP_WORDS[i+1]}
			break
		fi
	done

	# default to classpath
	[ -z "$sourcepath" ] && _java_find_classpath
	sourcepath=$classpath
}

# available classes completion
_java_classes()
{
	local classpath i

	# find which classpath to use
	_java_find_classpath

	# convert package syntax to path syntax
	cur=${cur//.//}
	# parse each classpath element for classes
	for i in ${classpath//:/ }; do
		if [ -r $i ] && [[ "$i" == *.@(jar|zip) ]]; then
			if type zipinfo &> /dev/null; then
				COMPREPLY=( ${COMPREPLY[@]} $( zipinfo -1 \
				"$i" | grep "^$cur" | grep '\.class$' | \
				grep -v "\\$" ) )
			else
				COMPREPLY=( ${COMPREPLY[@]} $( jar tf "$i" \
				"$cur" | grep "\.class$" | grep -v "\\$" ) )
			fi

		elif [ -d $i ]; then
			i=${i%/}
			COMPREPLY=( ${COMPREPLY[@]} $( find "$i" -type f \
			-path "$i/$cur*.class" 2>/dev/null | \
			grep -v "\\$" | sed -e "s|^$i/||" ) )
		fi
	done

	# remove class extension
	COMPREPLY=( ${COMPREPLY[@]%.class} )
	# convert path syntax to package syntax
	COMPREPLY=( ${COMPREPLY[@]//\//.} )
}

# available packages completion
_java_packages()
{
	local sourcepath i

	# find wich sourcepath to use
	_java_find_sourcepath

	# convert package syntax to path syntax
	cur=${cur//.//}
	# parse each sourcepath element for packages
	for i in ${sourcepath//:/ }; do
		if [ -d $i ]; then
			COMPREPLY=( ${COMPREPLY[@]} $( command ls -F -d \
				$i/$cur* 2>/dev/null | sed -e 's|^'$i'/||' ) )
		fi
	done
	# keep only packages
	COMPREPLY=( $( echo ${COMPREPLY[@]} | tr " " "\n" | grep "/$" ) )
	# remove packages extension
	COMPREPLY=( ${COMPREPLY[@]%/} )
	# convert path syntax to package syntax
	cur=${COMPREPLY[@]//\//.}
}

# java completion
#
_java()
{
	local cur prev i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	for ((i=1; i < $COMP_CWORD; i++)); do
		case ${COMP_WORDS[$i]} in
		    -cp|-classpath)
			((i++))	# skip the classpath string.
			;;
		    -*)
			# this is an option, not a class/jarfile name.
			;;
		    *)
			# once we've seen a class, just do filename completion
			_filedir
			return 0
			;;
		esac
	done

	case $prev in
		-@(cp|classpath))
			_java_path
			return 0
			;;
	esac

	if [[ "$cur" == -* ]]; then
		# relevant options completion
		COMPREPLY=( $( compgen -W '-client -hotspot -server -classic \
				-cp -classpath -D -verbose -verbose:class \
				-verbose:gc -version:jni -version \
				-showversion -? -help -X -jar \
				-ea -enableassertions -da -disableassertions \
				-esa -enablesystemassertions \
				-dsa -disablesystemassertions ' -- $cur ) )
	else
		if [[ "$prev" == -jar ]]; then
			# jar file completion
			_filedir jar
		else
			# classes completion
			_java_classes
		fi
	fi
}
complete -F _java $filenames java
}

# javadoc completion
#
have javadoc &&
_javadoc()
{
	COMPREPLY=()
	local cur prev

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case $prev in
		-@(overview|helpfile|stylesheetfile))
			_filedir
			return 0
			;;
		-d)
			_filedir -d
			return 0
			;;
		-@(classpath|bootclasspath|docletpath|sourcepath|extdirs))
			_java_path
			return 0
			;;
	esac

	if [[ "$cur" == -* ]]; then
		# relevant options completion
		COMPREPLY=( $( compgen -W '-overview -public -protected \
				-package -private -help -doclet -docletpath \
				-sourcepath -classpath -exclude -subpackages \
				-breakiterator -bootclasspath -source -extdirs \
				-verbose -locale -encoding -J -d -use -version \
				-author -docfilessubdirs -splitindex \
				-windowtitle -doctitle -header -footer -bottom \
				-link -linkoffline -excludedocfilessubdir \
				-group -nocomment -nodeprecated -noqualifier \
				-nosince -nodeprecatedlist -notree -noindex \
				-nohelp -nonavbar -quiet -serialwarn -tag \
				-taglet -tagletpath -charset -helpfile \
				-linksource -stylesheetfile -docencoding' -- \
				$cur ) )
	else
		# source files completion
		_filedir java
		# packages completion
		_java_packages
	fi
}
[ -n "${have:-}" ] && complete -F _javadoc $filenames javadoc

# javac completion
#
have javac &&
_javac()
{
	COMPREPLY=()
	local cur prev

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case $prev in
		-d)
			_filedir -d
			return 0
			;;
		-@(classpath|bootclasspath|sourcepath|extdirs))
			_java_path
			return 0
			;;
	esac

	if [[ "$cur" == -* ]]; then
		# relevant options completion
		COMPREPLY=( $( compgen -W '-g -g:none -g:lines -g:vars\
		-g:source -O -nowarn -verbose -deprecation -classpath\
		-sourcepath -bootclasspath -extdirs -d -encoding -source\
		-target -help' -- $cur ) )
	else
		# source files completion
		_filedir java
	fi
}
[ -n "${have:-}" ] && complete -F _javac $filenames javac

# PINE address-book completion
#
have pine &&
_pineaddr()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=( $( compgen -W '$( awk "{print \$1}" ~/.addressbook 2>/dev/null)' \
			-- $cur ) )
}
[ -n "${have:-}" ] && complete -F _pineaddr $default pine


# mutt completion
#
# Mutt doesn't have an "addressbook" like Pine, but it has aliases and
# a "query" function to retrieve addresses, so that's what we use here.
have mutt && {
_muttaddr()
{
	_muttaliases
	_muttquery
	return 0
}

_muttconffiles()
{
	local file sofar
	local -a newconffiles
	sofar=" $1 "
	shift
	while [[ "$1" ]]; do
	    newconffiles=( $(sed -rn 's/^source[[:space:]]+([^[:space:]]+).*$/\1/p' $(eval echo $1) ) )
	    for file in ${newconffiles[@]}; do
		[[ ! "$file" ]] || [[ "${sofar/ ${file} / }" != "$sofar" ]] &&
		    continue
		sofar="$sofar $file"
		sofar=" $(eval _muttconffiles \"$sofar\" $file) "
	    done
	    shift
	done
	echo $sofar
}

_muttaliases()
{
	local cur muttrc
	local -a conffiles aliases
	cur=${COMP_WORDS[COMP_CWORD]}

	[ -f ~/.mutt/muttrc ] && muttrc="~/.mutt/muttrc"
	[ -f ~/.muttrc ] && muttrc="~/.muttrc"
	[ -z "$muttrc" ] && return 0
	conffiles=( $(eval _muttconffiles $muttrc $muttrc) )
	aliases=( $( sed -rn 's/^alias[[:space:]]+([^[:space:]]+).*$/\1/p' \
			$(eval echo ${conffiles[@]}) ) )
	COMPREPLY=( ${COMPREPLY[@]} $( compgen -W "${aliases[*]}" -- $cur ) )

	return 0
}

_muttquery()
{
	local cur querycmd
	local -a queryresults
	cur=${COMP_WORDS[COMP_CWORD]}

	querycmd="$( mutt -Q query_command  | sed -r 's/^query_command=\"(.*)\"$/\1/; s/%s/'$cur'/' )"
	if [ -z "$cur" -o -z "$querycmd" ]; then
	    queryresults=()
	else 
	    queryresults=( $( $querycmd | \
	      sed -nr '2,$s/^([^[:space:]]+).*/\1/p' ) )
	fi

	COMPREPLY=( ${COMPREPLY[@]} $( compgen -W "${queryresults[*]}" \
			-- $cur ) )

	return 0
}

_muttfiledir()
{
	local cur folder spoolfile
	cur=${COMP_WORDS[COMP_CWORD]}

	# This is currently not working so well. Perhaps this function should
	# just call _filedir() for the moment.
	if [[ $cur == [=+]* ]]; then
		folder="$( mutt -Q folder | sed -r 's/^folder=\"(.*)\"$/\1/' )"
		[ ! -z "$folder" ] && eval cur="${cur/[=+]/$folder\/}"
	elif [ "$cur" == !* ]; then
		spoolfile="$( mutt -Q spoolfile | sed -r 's/^spoolfile=\"(.*)\"$/\1/' )"
		[ ! -z "$spoolfile" ] && eval cur="${cur/^!/$spoolfile}";
	fi
	_filedir

	return 0
}

_mutt()
{
	local cur prev
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	COMPREPLY=()

	case "$cur" in
	-*)
		COMPREPLY=( $( compgen -W '-A -a -b -c -e -f -F -H -i -m -n \
					    -p -Q -R -s -v -x -y -z -Z -h' \
					    -- $cur ) )
		return 0
		;;
	*)
	    case "$prev" in
	    -@(a|f|F|H|i))
		    _muttfiledir
		    return 0
		    ;;
	    -A)
		    _muttaliases
		    return 0
		    ;;
	    -@(e|m|Q|s|h|p|R|v|y|z|Z))
		    return 0
		    ;;
	    *)
		    _muttaddr
		    return 0
		    ;;
	    esac
	    ;;
	esac
	
}
complete -F _mutt $filenames mutt
}

_configure_func()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	# if $COMP_CONFIGURE_HINTS is not null, then completions of the form
	# --option=SETTING will include 'SETTING' as a contextual hint
	[[ "$cur" != -* ]] && return 0

	if [ -n "$COMP_CONFIGURE_HINTS" ]; then
		COMPREPLY=( $( $1 --help | awk '/^  --[A-Za-z]/ { print $1; if ($2 ~ /--[A-Za-z]/) print $2 }' | sed -e 's/[,[].*//g' | grep ^$cur ) )

	else
		COMPREPLY=( $( $1 --help | awk '/^  --[A-Za-z]/ { print $1; if ($2 ~ /--[A-Za-z]/) print $2 }' | sed -e 's/[,=[].*//g' | grep ^$cur ) )
	fi
}
complete -F _configure_func $default configure

# Debian reportbug(1) completion
#
have reportbug &&
_reportbug()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	    -f|--filename|-i|--include|--mta|-o|--output)
		_filedir
		return 0
		;;
	    -B|--bts)
		COMPREPLY=( $( compgen -W "debian guug kde mandrake help" -- \
			       $cur ))
		return 0
		;;
	    -e|--editor|--mua)
		COMP_WORDS=(COMP_WORDS[0] $cur)
		COMP_CWORD=1
		_command
		return 0
		;;
	    --mode)
		COMPREPLY=( $( compgen -W "novice standard expert" -- $cur ) )
		return 0
		;;
	    -S|--severity)
		COMPREPLY=( $( compgen -W "grave serious important normal \
					   minor wishlist" -- $cur ) )
		return 0
		;;
	    -u|--ui|--interface)
		COMPREPLY=( $( compgen -W "newt text gnome" -- $cur ) )
		return 0
		;;
	    -t|--type)
		COMPREPLY=( $( compgen -W "gnats debbugs" -- $cur ) )
		return 0
		;;
	    -T|--tags)
		COMPREPLY=( $( compgen -W "none patch security upstream sid \
					   woody potato sarge fixed" -- $cur ))
		return 0
		;;
	    *)
		;;
	esac
	
	COMPREPLY=($( compgen -W '-h --help -v --version -a --af -b \
			--no-query-bts --query-bts -B --bts -c --configure \
			--no-config-files --check-available -d --debug \
			--no-check-available -e --editor --email -f \
			--filename -g --gnupg -H --header -i --include -j \
			--justification -l --ldap --no-ldap -L --list-cc -m \
			--maintonly --mode --mua --mta --mutt -n --mh --nmh \
			-o --output -p --print -P --pgp --proxy --http_proxy\
			-q --quiet -Q --query-only --realname --report-quiet \
			--reply-to --replyto -s --subject -S --severity \
			--smtphost -t --type -T --tags --template -V -x \
			--no-cc --package-version -z --no-compress \
			--ui --interface -u \
			wnpp boot-floppies kernel-image' -- $cur ) \
	    		$( apt-cache pkgnames -- $cur ) )
	_filedir
	return 0
}
[ -n "${have:-}" ] && complete -F _reportbug $filenames reportbug

# Debian querybts(1) completion
#
have querybts &&
_querybts()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	    -B|--bts)
		COMPREPLY=( $( compgen -W "debian guug kde mandrake help" -- \
			       $cur ))
		return 0
		;;
	    -u|--ui|--interface)
		COMPREPLY=($( compgen -W "newt text gnome" -- $cur ))
		return 0
		;;
	    *)
		;;
	esac

	COMPREPLY=($( compgen -W '-h --help -v --version -A --archive \
			-B --bts -l --ldap --no-ldap --proxy= --http_proxy= \
			-s --source -w --web -u --ui --interface \
			wnpp boot-floppies' -- $cur ) \
	    		$( apt-cache pkgnames -- $cur ) )
}
[ -n "${have:-}" ] && complete -F _querybts $filenames querybts

# update-alternatives completion
#
have update-alternatives &&
_update_alternatives()
{
	installed_alternatives()
	{
		local admindir
		# find wich admin dir to use
		if [ -f /etc/debian_version ]; then
			admindir=/var/lib/dpkg/alternatives
		else
			admindir=/var/lib/rpm/alternatives
		fi
		for (( i=1; i < COMP_CWORD; i++ )); do
			if [[ "${COMP_WORDS[i]}" == --admindir ]]; then
				admindir=${COMP_WORDS[i+1]}
				break
			fi
		done
		COMPREPLY=( $( command ls $admindir | grep "^$cur" ) )
	}

	local cur prev mode args

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	--@(altdir|admindir))
		_filedir -d
		return 0
		;;
	--@(help|version))
		return 0
		;;
	esac

	# find wich mode to use and how many real args used so far
	for (( i=1; i < COMP_CWORD; i++ )); do
		if [[ "${COMP_WORDS[i]}" == --@(install|remove|auto|display|config) ]]; then
			mode=${COMP_WORDS[i]}
			args=$(($COMP_CWORD - i))
			break
		fi
	done

	case $mode in
	--install)
		case $args in
		1)
			_filedir
			;;
		2)
			installed_alternatives
			;;
		3)
			_filedir
			;;
		esac
		;;
	--remove)
		case $args in
		1)
			installed_alternatives
			;;
		2)
			_filedir
			;;
		esac
		;;
	--auto)
		installed_alternatives
		;;
	--display)
		installed_alternatives
		;;
	--config)
		installed_alternatives
		;;
	*)
		COMPREPLY=( $( compgen -W '--verbose --quiet --help --version \
			       --altdir --admindir' -- $cur ) \
			    $( compgen -W '--install --remove --auto --display \
			       --config' -- $cur ) )
	esac
}
[ -n "${have:-}" ] && complete -F _update_alternatives update-alternatives

# Python completion
#
have python &&
_python()
{
	local prev cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-Q)
		COMPREPLY=( $( compgen -W "old new warn warnall" -- $cur ) )
		return 0
		;;
	-W)
		COMPREPLY=( $( compgen -W "ignore default all module once error" -- $cur ) )
		return 0
		;;
	-c)
		_filedir '@(py|pyc|pyo)'
		return 0
		;;
	!(python|-?))
		[[ ${COMP_WORDS[COMP_CWORD-2]} != -@(Q|W) ]] && _filedir
		;;
	esac


	# if '-c' is already given, complete all kind of files.
	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
		if [[ ${COMP_WORDS[i]} == -c ]]; then
			_filedir
		fi
	done


	if [[ "$cur" != -* ]]; then
		_filedir '@(py|pyc|pyo)'
	else
		COMPREPLY=( $( compgen -W "- -d -E -h -i -O -Q -S -t -u \
					   -U -v -V -W -x -c" -- $cur ) )
	fi



	return 0
}
[ -n "${have:-}" ] && complete -F _python $filenames python

# Perl completion
#
have perl &&
{
_perlmodules()
{
    COMPREPLY=( $( compgen -P "$prefix" -W "$( perl -e 'sub mods { my ($base,$dir)=@_; return if  $base !~ /^\Q$ENV{cur}/; chdir($dir) or return; for (glob(q[*.pm])) {s/\.pm$//; print qq[$base$_\n]}; mods(/^(?:[.\d]+|$Config{archname}-$Config{osname}|auto)$/ ? undef : qq[${base}${_}\\\\:\\\\:],qq[$dir/$_]) for grep {-d} glob(q[*]); } mods(undef,$_) for @INC;' )" -- $cur ) )
}

_perl()
{
    local cur prev prefix temp

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    prefix=""

    # completing an option (may or may not be separated by a space)
    if [[ "$cur" == -?* ]]; then
	temp=$cur
	prev=${temp:0:2}
	cur=${temp:2}
	prefix=$prev
    fi

    # only handle module completion for now
    case "$prev" in
	-m|-M)
	    _perlmodules
	    return 0
	    ;;
    esac

    # handle case where first parameter is not a dash option
    if [ $COMP_CWORD -eq 1 ] && [[ "$cur" != -* ]]; then
	_filedir
	return 0
    fi

    # complete using basic options
    COMPREPLY=( $( compgen -W '-C -s -T -u -U -W -X -h -v -V -c -w -d -D -p \
			-n -a -F -l -0 -I -m -M -P -S -x -i -e ' -- $cur ) )
    return 0
}
complete -F _perl $default perl

_perldoc()
{
    local cur prev prefix temp

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    prefix=""

    # completing an option (may or may not be separated by a space)
    if [[ "$cur" == -?* ]]; then
	temp=$cur
	prev=${temp:0:2}
	cur=${temp:2}
	prefix=$prev
    fi

    # complete builtin perl functions
    case $prev in
	-f)
	    COMPREPLY=( $( compgen -W 'chomp chop chr crypt hex index lc \
	    lcfirst length oct ord pack q qq reverse rindex sprintf \
	    substr tr uc ucfirst y m pos quotemeta s split study qr abs \
	    atan2 cos exp hex int log oct rand sin sqrt srand pop push \
	    shift splice unshift grep join map qw reverse sort unpack \
	    delete each exists keys values binmode close closedir \
	    dbmclose dbmopen die eof fileno flock format getc print \
	    printf read readdir rewinddir seek seekdir select syscall \
	    sysread sysseek syswrite tell telldir truncate warn write \
	    pack read syscall sysread syswrite unpack vec -X chdir chmod \
	    chown chroot fcntl glob ioctl link lstat mkdir open opendir \
	    readlink rename rmdir stat symlink umask unlink utime caller \
	    continue do dump eval exit goto last next redo return \
	    sub wantarray caller import local my our package use defined \
	    formline reset scalar undef \
	    alarm exec fork getpgrp getppid getpriority kill pipe qx \
	    setpgrp setpriority sleep system times wait waitpid \
	    import no package require use bless dbmclose dbmopen package \
	    ref tie tied untie use accept bind connect getpeername \
	    getsockname getsockopt listen recv send setsockopt shutdown \
	    socket socketpair msgctl msgget msgrcv msgsnd semctl semget \
	    semop shmctl shmget shmread shmwrite endgrent endhostent \
	    endnetent endpwent getgrent getgrgid getgrnam getlogin \
	    getpwent getpwnam getpwuid setgrent setpwent endprotoent \
	    endservent gethostbyaddr gethostbyname gethostent \
	    getnetbyaddr getnetbyname getnetent getprotobyname \
	    getprotobynumber getprotoent getservbyname getservbyport \
	    getservent sethostent setnetent setprotoent setservent \
	    gmtime localtime time times' -- $cur ) )
	    return 0
	    ;;
    esac

    case $cur in
	-*)
	    COMPREPLY=( $( compgen -W '-h -v -t -u -m -l -F -X -f -q' -- $cur ))
	    return 0
	    ;;
	*/*)
	    return 0
	    ;;
	*)
	    _perlmodules
	    COMPREPLY=( ${COMPREPLY[@]} $( compgen -W '$( PAGER=cat man perl 2>/dev/null | sed -ne "/perl.*Perl overview/,/perlwin32/s/^[^a-z0-9]*\([a-z0-9]*\).*$/\1/p")' -- $cur ) )

	    return 0
	    ;;
    esac
}
complete -F _perldoc $default perldoc
}

# rcs(1) completion
#
have rcs &&
_rcs()
{
	local cur prev file dir

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	file=${cur##*/}
	dir=${cur%/*}

	# deal with relative directory
	[ "$file" = "$dir" ] && dir=.

	COMPREPLY=( $( compgen -f "$dir/RCS/$file" ) )

	for (( i=0; i < ${#COMPREPLY[@]}; i++ )); do
		file=${COMPREPLY[$i]##*/}
		file=${file%,v}
		dir=${COMPREPLY[$i]%RCS/*}
		COMPREPLY[$i]=$dir$file
	done

	# default to files if nothing returned and we're checking in.
	# otherwise, default to directories
	[ ${#COMPREPLY[@]} -eq 0 -a $1 = ci ] && _filedir || _filedir -d
}
[ -n "${have:-}" ] && complete -F _rcs $filenames ci co rlog rcs rcsdiff

# lilo(8) completion
#
have lilo &&
_lilo()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case $prev in
		-@(C|i|m|s|S))
			_filedir
			return 0
			;;
		-r)
			_filedir -d
			return 0
			;;
		-@(I|D|R))
			# label completion
			COMPREPLY=( $( awk -F'=' '/label/ {print $2}' \
					/etc/lilo.conf | grep "^$cur" ) )
			return 0
			;;
		-@(A|b|M|u|U))
			# device completion
			cur=${cur:=/dev/}
			_filedir
			return 0
			;;
		-T)
			# topic completion
			COMPREPLY=( $( compgen -W 'help ChRul EBDA geom geom= \
					table= video' -- $cur ) )
			return 0
			;;
	esac

	if [[ "$cur" == -* ]]; then
		# relevant options completion
		COMPREPLY=( $( compgen -W '-A -b -c -C -d -f -g -i -I -l -L -m \
			-M -p -P -q -r -R -s -S -t -T -u -U -v -V -w -x -z' -- \
			$cur ) )
	fi
}
[ -n "${have:-}" ] && complete -F _lilo lilo

# links completion
#
have links &&
_links()
{
	local cur
  
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
  
	case "$cur" in
	    --*)
		COMPREPLY=( $( compgen -W '--help' -- $cur ) )
		;;
	    -*)
		COMPREPLY=( $( compgen -W '-async-dns -max-connections \
				-max-connections-to-host -retries \
				-receive-timeout -unrestartable-receive-timeout\
				-format-cache-size -memory-cache-size \
				-http-proxy -ftp-proxy -download-dir \
				-assume-codepage -anonymous -dump -no-connect \
				-source -version -help' -- $cur ) )
		;;
	    *)
		if [ -r ~/.links/links.his ]; then
		    COMPREPLY=( $( compgen -W '$( < ~/.links/links.his )' \
				   -- $cur ) )
		fi
				_filedir '@(htm|html)'
				return 0
		;;
	esac
  
	return 0
}
[ -n "${have:-}" ] && complete -F _links $filenames links

[ $UNAME = FreeBSD ] && {
# FreeBSD package management tool completion
#
_pkg_delete()
{
	local cur pkgdir prev

	pkgdir=${PKG_DBDIR:-/var/db/pkg}/
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	test "$prev" = "-o" -o "$prev" = "-p" -o "$prev" = "-W" && return 0

	COMPREPLY=( $( compgen -d $pkgdir$cur ) )
	COMPREPLY=( ${COMPREPLY[@]#$pkgdir} )

	return 0
}
complete -F _pkg_delete $dirnames pkg_delete pkg_info
have pkg_deinstall && complete -F _pkg_delete $dirnames pkg_deinstall

# FreeBSD kernel module commands
#
_kldload()
{
	local cur moddir

	moddir=/modules/
	[ -d $moddir ] || moddir=/boot/kernel/
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=( $( compgen -f $moddir$cur ) )
	COMPREPLY=( ${COMPREPLY[@]#$moddir} )
	COMPREPLY=( ${COMPREPLY[@]%.ko} )

	return 0
}
complete -F _kldload $filenames kldload

_kldunload()
{
	local cur
	cur=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=( $(kldstat | sed -ne "s/^.*[ \t]\+\($cur[a-z_]\+\).ko$/\1/p") )
}
complete -F _kldunload $filenames kldunload
}

# FreeBSD portupgrade completion
#
have portupgrade &&
_portupgrade()
{
	local cur pkgdir prev

	pkgdir=${PKG_DBDIR:-/var/db/pkg}/
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	test "$prev" = "-l" -o "$prev" = "-L" -o "$prev" = "-o" && return 0

	COMPREPLY=( $( compgen -d $pkgdir$cur ) )
	COMPREPLY=( ${COMPREPLY[@]#$pkgdir} )
	COMPREPLY=( ${COMPREPLY[@]%-*} )

	return 0
}
[ -n "${have:-}" ] && complete -F _portupgrade $dirnames portupgrade

# FreeBSD portinstall completion
#
have portinstall &&
_portinstall()
{
	local cur portsdir prev indexfile
	local -a COMPREPLY2

	portsdir=${PORTSDIR:-/usr/ports}/
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	# First try INDEX-5
	indexfile=$portsdir/INDEX-5
	# Then INDEX if INDEX-5 does not exist or system is not FreeBSD 5.x
	[ "${OSTYPE%.*}" = "freebsd5" -a -f $indexfile ] ||
	  indexfile=$portsdir/INDEX

	[ "$prev" = "-l" -o "$prev" = "-L" -o "$prev" = "-o" ] && return 0

	COMPREPLY=( $( egrep "^$cur" < $indexfile | cut -d'|' -f1 ) )
	COMPREPLY2=( $( egrep "^[^\|]+\|$portsdir$cur" < $indexfile | \
			cut -d'|' -f2 ) )
	COMPREPLY2=( ${COMPREPLY2[@]#$portsdir} )
	COMPREPLY=( ${COMPREPLY[@]} ${COMPREPLY2[@]} )

	return 0
}
[ -n "${have:-}" ] && complete -F _portinstall $dirnames portinstall

# Slackware Linux removepkg completion
#
have removepkg && [ -f /etc/slackware-version ] &&
_removepkg()
{
	local packages cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=( $( (cd /var/log/packages; compgen -f -- "$cur") ) )
}
[ -n "${have:-}" ] && complete -F _removepkg $filenames removepkg &&
	complete $dirnames -f -X '!*.tgz' installpkg upgradepkg explodepkg

# look(1) completion
#
have look && 
_look()
{
	local cur
  
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ $COMP_CWORD = 1 ]; then
		COMPREPLY=( $( compgen -W '$(look $cur)' ) )
	fi
}
[ -n "${have:-}" ] && complete -F _look $default look

# ypcat(1) and ypmatch(1) completion
#
have ypmatch &&
_ypmatch()
{
	local cur map

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	[ $1 = ypcat ] && [ $COMP_CWORD -gt 1 ] && return 0
	[ $1 = ypmatch ] && [ $COMP_CWORD -gt 2 ] && return 0

	if [ $1 = ypmatch ] && [ $COMP_CWORD -eq 1 ] && \
	   [ ${#COMP_WORDS[@]} -eq 3 ]; then
		map=${COMP_WORDS[2]}
		COMPREPLY=( $( compgen -W '$( ypcat $map | \
						cut -d':' -f 1 )' -- $cur) )
	else
		[ $1 = ypmatch ] && [ $COMP_CWORD -ne 2 ] && return 0
		COMPREPLY=( $( compgen -W \
			      '$( echo $(ypcat -x | cut -d"\"" -f 2))' -- $cur))
	fi

	return 0
}
[ -n "${have:-}" ] && complete -F _ypmatch ypmatch ypcat

# mplayer(1) completion
#
have mplayer && {
_mplayer_options_list()
{
	cur=${cur%\\}
	COMPREPLY=( $( $1 $2 help 2> /dev/null | \
		sed -e '1,/^Available/d' | awk '{print $1}' | \
		sed -e 's/:$//' -e 's/^'${2#-}'$//' -e 's/<.*//' | \
		grep "^$cur" ) )
}

_mplayer()
{
	local cmd cur prev skinsdir IFS=$' \t\n' i j k=0

	COMPREPLY=()
	cmd=${COMP_WORDS[0]}
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
		-@(ac|afm|vc|vfm|ao|vo|vop|fstype))
			_mplayer_options_list mplayer $prev
			return 0
			;;
		-@(oac|ovc|of))
			_mplayer_options_list mencoder $prev
			return 0
			;;
		-audiofile)
			_filedir '@(mp3|MP3|mpg|MPG|ogg|OGG|wav|WAV)'
			return 0
			;;
		-font)
			_filedir '@(desc|ttf)'
			return 0
			;;
		-sub)
			_filedir '@(srt|SRT|sub|SUB|txt|TXT|utf|UTF|rar|RAR)'
			return 0
			;;
		-vobsub)
			_filedir '@(idx|IDX|ifo|IFO|sub|SUB)'
			IFS=$'\t\n' 
			COMPREPLY=( $( for i in ${COMPREPLY[@]}; do
						if [ -f $i -a -r $i ]; then
							echo ${i%.*}
						else
							echo $i
						fi
				       done ) )
			IFS=$' \t\n' 
			return 0
			;;
		-ifo)
			_filedir '@(ifo|IFO)'
			return 0
			;;
		-cuefile)
			_filedir '@(bin|BIN|cue|CUE)'
			return 0
			;;
		-skin)
			# if you don't have installed mplayer in /usr/local you
			# may want to set the MPLAYER_SKINS_DIR global variable
			if [ -n "$MPLAYER_SKINS_DIR" ]; then
				skinsdir=$MPLAYER_SKINS_DIR
			else
				skinsdir=/usr/local/share/mplayer/Skin
			fi

			IFS=$'\t\n' 
			for i in ~/.mplayer/Skin $skinsdir; do
				if [ -d $i -a -r $i ]; then
					for j in $( compgen -d $i/$cur ); do
						COMPREPLY[$k]=${j#$i/}
						k=$((++k))
					done
				fi
			done
			IFS=$' \t\n' 
			return 0
			;;
		-@(mixer|@(cdrom|dvd)-device|dvdauth|fb|zrdev))
			cur=${cur:=/dev/}
			_filedir
			return 0
			;;
		-@(edl?(out)|lircconf|menu-cfg|playlist|csslib|dumpfile)| \
		-@(subfile|vobsub|aofile|fbmodeconfig|include|o|dvdkey)| \
		-passlogfile)
			_filedir
			return 0
			;;
		-@(auto@(q|sync)|loop|menu-root|speed|sstep|aid|alang)| \
		-@(?(@(audio|sub)-)demuxer|bandwidth|cache|chapter)| \
		-@(dvd?(angle)|fps|frames|mc|passwd|user|sb|srate|ss|vcd)| \
		-@(vi?(d|vo)|ffactor|sid|slang|spu@(align|aa|gauss))| \
		-@(vobsubid|delay|bpp|brightness|contrast|dfbopts|display)| \
		-@(fbmode|geometry|guiwid|hue|icelayer|screen[wh]|wid)| \
		-@(monitor@(aspect|_@(dotclock|[hv]freq))|panscan|saturation)| \
		-@(xineramascreen|zr@(crop|norm|quality|[xy]doff|[vh]dec))| \
		-@(aspect|pp|x|y|xy|z|stereo|audio-@(density|delay|preload))| \
		-@(endpos|osdlevel|ffourcc|sws|channels|skiplimit|format)| \
		-@(ofps|aa@(driver|@(osd|sub)color)|vobsubout?(i@(ndex|d)))| \
		-sub@(-bg-@(alpha|color)|cp|delay|fps|pos|align|width)| \
		-sub@(font-@(blur|outline|autoscale|encoding|@(osd|text)-scale)))
			return 0
			;;
		-lavdopts)
			COMPREPLY=( $( compgen -W 'ec er= bug= idct= gray' \
					-- $cur ) )
			return 0
			;;
		-lavcopts)
			COMPREPLY=( $( compgen -W 'vcodec= vqmin= vqscale= \
					vqmax= mbqmin= mbqmax= vqdiff= \
					vmax_b_frames= vme= vhq v4mv \
					keyint= vb_strategy= vpass= \
					aspect= vbitrate= vratetol= \
					vrc_maxrate= vrc_minrate= \
					vrc_buf_size= vb_qfactor= vi_qfactor= \
					vb_qoffset= vi_qoffset= vqblur= \
					vqcomp= vrc_eq= vrc_override= \
					vrc_init_cplx= vqsquish= vlelim= \
					vcelim= vstrict= vdpart vpsize= gray \
					vfdct= idct= lumi_mask= dark_mask= \
					tcplx_mask= scplx_mask= naq ildct \
					format= pred qpel precmp= cmp= \
					subcmp= predia= dia= trell last_pred= \
					preme= subq= psnr mpeg_quant aic umv' \
					-- $cur ) )
			return 0
			;;
		-ssf)
			COMPREPLY=( $( compgen -W 'lgb= cgb= ls= cs= chs= \
					cvs=' -- $cur ) )
			return 0
			;;
		-jpeg)
			COMPREPLY=( $( compgen -W 'noprogressive progressive \
					nobaseline baseline optimize= \
					smooth= quality= outdir=' -- $cur ) )
			return 0
			;;
		-xvidopts)
			COMPREPLY=( $( compgen -W 'dr2 nodr2' -- $cur ) )
			return 0
			;;
		-xvidencopts)
			COMPREPLY=( $( compgen -W 'pass= bitrate= \
					fixed_quant= me_quality= 4mv \
					rc_reaction_delay_factor= \
					rc_averaging_period= rc_buffer= \
					quant_range= min_key_interval= \
					max_key_interval= mpeg_quant \
					mod_quant lumi_mask hintedme \
					hintfile debug keyframe_boost= \
					kfthreshold= kfreduction=' -- $cur ) )
			return 0
			;;
		-divx4opts)
			COMPREPLY=( $( compgen -W 'br= key= deinterlace q= \
					min_quant= max_quant= rc_period= \
					rc_reaction_period= crispness= \
					rc_reaction_ratio= pass= vbrpass= \
					help' -- $cur ) )
			return 0
			;;
		-info)
			COMPREPLY=( $( compgen -W 'name= artist= genre= \
					subject= copyright= srcform= \
					comment= help' -- $cur ) )
			return 0
			;;
		-lameopts)
			COMPREPLY=( $( compgen -W 'vbr= abr cbr br= q= aq= \
					ratio= vol= mode= padding= fast \
					preset= help' -- $cur ) )
			return 0
			;;
		-rawaudio)
			COMPREPLY=( $( compgen -W 'on channels= rate= \
					samplesize= format=' -- $cur ) )
			return 0
			;;
		-rawvideo)
			COMPREPLY=( $( compgen -W 'on fps= sqcif qcif cif \
					4cif pal ntsc w= h= y420 yv12 yuy2 \
					y8 format= size=' -- $cur ) )
			return 0
			;;
		-aop)
			COMPREPLY=( $( compgen -W 'list= delay= format= fout= \
					volume= mul= softclip' -- $cur ) )
			return 0
			;;
		-dxr2)
			COMPREPLY=( $( compgen -W 'ar-mode= iec958-encoded \
					iec958-decoded mute ucode= 75ire bw \
					color interlaced macrovision= norm= \
					square-pixel ccir601-pixel cr-left= \
					cr-right= cr-top= cr-bot= ck-rmin= \
					ck-gmin= ck-bmin= ck-rmax= ck-gmax= \
					ck-bmax= ck-r= ck-g= ck-b= \
					ignore-cache= ol-osd= olh-cor= \
					olw-cor= olx-cor= oly-cor= overlay \
					overlay-ratio= update-cache' -- $cur ))
			return 0
			;;
		-tv)
			COMPREPLY=( $( compgen -W 'on noaudio driver= device= \
					input= freq= outfmt= width= height= \
					buffersize= norm= channel= chanlist= \
					audiorate= forceaudio alsa amode= \
					forcechan= adevice= audioid= volume= \
					bass= treble= balance= fps= \
					channels= immediatemode=' -- $cur ) )
			return 0
			;;
		-mf)
			COMPREPLY=( $( compgen -W 'on w= h= fps= type=' \
					-- $cur ) )
			return 0
			;;
		-cdda)
			COMPREPLY=( $( compgen -W 'speed= paranoia= \
					generic-dev= sector-size= overlap= \
					toc-bias toc-offset= skip noskip' \
					-- $cur ) )
			return 0
			;;
		-input)
			COMPREPLY=( $( compgen -W 'conf= ar-delay ar-rate \
					keylist cmdlist js-dev file' -- $cur ) )
			return 0
			;;
		-af)
			COMPREPLY=( $( compgen -W 'resample resample= \
					channels channels= format format= \
					volume volume= delay delay= pan \
					pan= sub sub= surround surround=' \
					-- $cur ) )
			return 0
			;;
		-af-adv)
			COMPREPLY=( $( compgen -W 'force= list=' -- $cur ) )
			return 0
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W '-aid -alang -audio-demuxer \
					-audiofile -cdrom-device -cache -cdda \
					-channels -chapter -csslib -demuxer \
					-dvd -dvd-device -dvdangle -dvdauth \
					-dvdkey -dvdnav -forceidx -fps -frames \
					-hr-mp3-seek -idx -mc -mf -ni -nobps \
					-passwd -rawaudio -rtsp-stream-over-tcp\
					-skipopening -sb -srate -ss -tv -user \
					-vcd -vid -vivo -ifo -ffactor -font \
					-noautosub -nooverlapsub -sid -slang \
					-sub -subcc -subcp -sub-demuxer \
					-subdelay -subfont-autoscale \
					-subfont-blur -subfont-encoding \
					-subfont-osd-scale -subfont-outline \
					-subfont-text-scale -subfps -subfile \
					-subpos -unicode -utf8 -vobsub \
					-vobsubid -ac -afm -aspect -flip \
					-lavdopts -noaspect -nosound -pp -ssf \
					-stereo -sws -vc -vfm -vop -xvidopts\
					-xy -zoom -bandwidth -cuefile \
					-noextbased -rawvideo -overlapsub \
					-sub-bg-alpha -sub-bg-color -subalign \
					-subwidth -sub-no-text-pp -spualign \
					-spuaa -spugauss -pphelp -verbose -v \
					-noni -noidx -nohr-mp3-seek -extbased \
					-bps -oldpp -nozoom -noflip -nounicode \
					-noutf8' -- $cur ) )
			# add mplayer specific options
			[[ "$cmd" == @(?(g)mplayer) ]] && COMPREPLY=( ${COMPREPLY[@]} \
				$(compgen -W '-autoq -autosync -benchmark \
					-framedrop -h -help -hardframedrop \
					-identify -input -lircconf -loop \
					-nojoystick -nolirc -nortc -playlist \
					-quiet -really-quiet -rnd -sdp -skin \
					-slave -softsleep -speed -sstep \
					-use-stdin -dumpaudio -dumpfile \
					-dumpstream -dumpvideo -dumpmicrodvdsub\
					-dumpmpsub -dumpsrtsub -dumpjacosub \
					-dumpsami -dumpsub -osdlevel -af \
					-af-adv -ao -aofile -aop -delay -mixer \
					-nowaveheader -bpp -brightness \
					-contrast -display -double -dr -dxr2 \
					-fb -fbmode -fbmodeconfig -forcexv -fs \
					-geometry -hue -icelayer -jpeg \
					-monitor_dotclock -monitor_hfreq \
					-monitor_vfreq -monitoraspect \
					-nograbpointer -noslices -panscan \
					-rootwin -saturation -screenw -screenh \
					-stop_xscreensaver -vm -vo -vsync -wid \
					-xineramascreen -z -zrbw -zrcrop \
					-zrdev -zrfd -zrhelp -zrnorm -zrquality \
					-zrvdec -zrhdec -zrxdoff -zrydoff -y \
					-edl -edlout -enqueue -fixed-vo \
					-menu -menu-root -menu-cfg -shuffle \
					-format -aahelp -dfbopts -fstype \
					-guiwid -nokeepaspect -x --help \
					-aaosdcolor -aasubcolor -aadriver \
					-aaextended -aaeight' -- $cur) )
			# add mencoder specific options
			[[ "$cmd" = mencoder ]] && COMPREPLY=( ${COMPREPLY[@]} \
				$(compgen -W '-audio-density -audio-delay \
					-audio-preload -divx4opts -endpos \
					-ffourcc -include -info -lameopts \
					-lavcopts -noskip -o -oac -ofps -ovc \
					-passlogfile -skiplimit -vobsubout \
					-vobsuboutindex -vobsuboutid \
					-xvidencopts -of --verbose' -- $cur) )
			;;
		*)
			_filedir '@(mp?(e)g|MP?(E)G|wm[av]|WM[AV]|avi|AVI|asf|ASF|vob|VOB|bin|BIN|dat|DAT|vcd|VCD|ps|PS|pes|PES|fli|FLI|viv|VIV|rm|RM|ram|RAM|yuv|YUV|mov|MOV|qt|QT|mp[34]|MP[34]|og[gm]|OG[GM]|wav|WAV|dump|DUMP|mkv|MKV|m4a|M4A|aac|AAC|m2v|M2V)'
			;;
	esac

	return 0
}
}
[ -n "${have:-}" ] && complete $filenames -F _mplayer mplayer mencoder gmplayer

# KDE dcop completion
#
have dcop &&
_dcop()
{
	local cur compstr

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	if [ -z $cur ]; then
	    compstr=${COMP_WORDS[*]}
	else
	    compstr=$( command echo ${COMP_WORDS[*]} | sed "s/ $cur$//" )
	fi
	COMPREPLY=( $( compgen -W '$( command $compstr | sed s/\(.*\)// )'  -- $cur ) )
}
[ "${have:-}" ] && complete -F _dcop dcop

# wvdial(1) completion
#
have wvdial &&
_wvdial()
{
	local cur prev config i IFS=$'\t\n'

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case $prev in
		--config)
			_filedir
			return 0
			;;
	esac

	case $cur in
		-*)
			COMPREPLY=( $( compgen -W '--config --chat \
				--remotename --help --version --no-syslog' \
				-- $cur ) )
			;;
		*)
			# start with global and personal config files
		       	config="/etc/wvdial.conf"$'\t'"$HOME/.wvdialrc"
			# replace with command line config file if present
			for (( i=1; i < COMP_CWORD; i++ )); do
				if [[ "${COMP_WORDS[i]}" == "--config" ]]; then
					config=${COMP_WORDS[i+1]}
					break
				fi
			done
			# parse config files for sections and
			# remove default section
			COMPREPLY=( $( sed -ne \
				    "s|^\[Dialer \($cur.*\)\]$|\1|p" \
				    $config 2>/dev/null |grep -v '^Defaults$'))
			# escape spaces
			COMPREPLY=${COMPREPLY// /\\ }
			;;
	esac

}
[ -n "${have:-}" ] && complete -F _wvdial wvdial

# gpg(1) completion
#
have gpg &&
_gpg() 
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
	-@(s|-sign|-clearsign|-decrypt-files|-load-extension)) 
		_filedir
		return 0
		;;
	--@(export|@(?(l|nr|nrl)sign|edit)-key)) 
		# return list of public keys
		COMPREPLY=( $( compgen -W "$( gpg --list-keys 2>/dev/null | sed -ne 's@^pub.*/\([^ ]*\).*\(<\([^>]*\)>\).*$@\1 \3@p')" -- "$cur" ))
		return 0
		;;
	-@(r|-recipient))
		COMPREPLY=( $( compgen -W "$( gpg --list-keys 2>/dev/null | sed -ne 's@^pub.*<\([^>]*\)>.*$@\1@p')" -- "$cur" ))
		if [ -e ~/.gnupg/gpg.conf ]; then
			COMPREPLY=( ${COMPREPLY[@]} $( compgen -W "$( sed -ne 's@^[ \t]*group[ \t][ \t]*\([^=]*\).*$@\1@p' ~/.gnupg/gpg.conf  )" -- "$cur") )
		fi
		return 0
		;;
	esac

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-s -b -e -f -c -d -a -r -u -Z -o -v \
				-q -n -N --sign --clearsign --detach-sign \
				--encrypt --encrypt-files --symmetric --store \
				--decrypt --decrypt-files --verify --list-keys \
				--list-sigs --check-sigs --fingerprint \
				--list-secret-keys --gen-key --delete-keys \
				--delete-secret-keys --sign-key --lsign-key \
				--nrsign-key --nrlsign-key --edit-key \
				--gen-revoke --export --send-key --recv-keys \
				--search-keys --refresh-keys --import \
				--list-packets --export-ownertrust \
				--import-ownertrust --update-trustdb \
				--check-trustdb --fix-trustdb --dearmor \
				--enarmor --print-md --armor --recipient \
				--default-recipient --default-recipient-self \
				--local-user --textmode --output --verbose \
				--quiet --no-tty --force-v3-sigs \
				--no-force-v3-sigs --force-v4-certs \
				--no-force-v4-certs --force-mdc --disable-mdc \
				--dry-run --use-agent --batch --yes --no \
				--keyring --secret-keyring --show-keyring \
				--default-key --keyserver --charset --options \
				--status-fd --trusted-key --load-extension \
				--rfc1991 --openpgp --pgp2 --s2k-mode \
				--s2k-digest-algo --s2k-cipher-algo \
				--cipher-algo --digest-algo --compress-algo \
				--throw-keyid --show-photos --no-show-photos \
				--photo-viewer --notation-data' -- $cur ) )
	 fi

}
[ "${have:-}" ] && complete -F _gpg $default gpg

# iconv(1) completion
#
have iconv &&
_iconv()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [[ "$cur" = -* ]]; then
		COMPREPLY=( $( compgen -W '--from-code -f --to-code -t --list
		--output -o --verbose' -- "$cur" ) )
		return 0
	fi
	

	if [[ "$prev" == -@(f|t|-@(from|to)-code) ]]; then
		COMPREPLY=( $( compgen -W \
		    '$( iconv --list | sed "1,/^$/d; s@//@@;" )' -- "$cur" ) )
	fi
		
	return 0
}
[ -n "${have:-}" ] && complete -F _iconv $default iconv

# dict(1) completion
#
{ have dict || have rdict; } && {
_dictdata()
{
	dict $host $port $1 2>/dev/null | sed -ne \
	    's/^['$'\t '']['$'\t '']*\([^'$'\t '']*\).*$/\1/p'
}

_dict()
{
	local cur prev host port db dictfile

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}
	dictfile=/usr/share/dict/words

	for (( i=1; i < COMP_CWORD; i++ )); do
		case "${COMP_WORDS[i]}" in
		-@(h|--host))
			host=${COMP_WORDS[i+1]}
			[ -n "$host" ] && host="-h $host"
			i=$((++i))
			;;
		-@(p|-port))
			port=${COMP_WORDS[i+1]}
			[ -n "$port" ] && port="-p $port"
			i=$((++i))
			;;
		-@(d|-database))
			db=${COMP_WORDS[i+1]}
			[ -n "$db" ] && host="-d $db"
			i=$((++i))
			;;
		*)
			;;
		esac
	done

	if [[ "$cur" = -* ]]; then
		COMPREPLY=( $( compgen -W '-h --host -p --port -d --database \
			       -m --match -s --strategy -c --config -C \
			       --nocorrect -D --dbs -S --strats -H \
			       --serverhelp -i --info -I --serverinfo \
			       -a --noauth -u --user -k --key -V --version \
			       -L --license --help -v --verbose -r --raw \
			       -P --pager --debug --html --pipesize --client' \
			       -- "$cur" ) )
		return 0
	fi

	case "$prev" in
	-@(d|-database|i|info))
		COMPREPLY=( $( compgen -W '$( _dictdata -D )' -- "$cur" ) )
		return 0
		;;
	-@(s|-strategy))
		COMPREPLY=( $( compgen -W '$( _dictdata -S )' -- "$cur" ) )
		return 0
		;;
	*)
		;;
	esac

	[ -r $dictfile ] && \
		COMPREPLY=( $( compgen -W '$( cat $dictfile )' -- "$cur" ) )
}
complete -F _dict $default dict rdict
}

# cdrecord(1) completion
#
have cdrecord &&
_cdrecord()
{
	local cur prev i generic_options track_options track_mode

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	# foo=bar style option
	if [[ "$cur" == *=* ]]; then
		prev=${cur/=*/}
		cur=${cur/*=/}
		case "$prev" in
			@(text|cue)file)
				_filedir
				return 0
				;;
			blank)
				COMPREPLY=( $( compgen -W 'help all fast \
				track unreserve trtail unclose session' \
				-- $cur ) )
				return 0
				;;
			driveropts)
				COMPREPLY=( $( compgen -W 'burnfree noburnfree\
				  varirec= audiomaster forcespeed noforcespeed\
				  speedread nospeedread singlesession \
				  nosinglesession hidecdr nohidecdr tattooinfo\
				  tattoofile=' -- $cur ) )
				return 0
				;;
		esac
	fi

	generic_options=(-version -v -V -d -silent -s -force -immed -dummy \
			 -dao -raw -raw96r -raw96p -raw16 -multi -msinfo -toc \
			 -atip -fix -nofix -waiti -load -lock -eject -format \
			 -setdropts -checkdrive -prcap -inq -scanbus -reset \
			 -abort -overburn -ignsize -useinfo -packet -noclose \
			 -text debug= kdebug= kd= minbuf= speed= blank= fs= \
			 dev= gracetime= timeout= driver= driveropts= \
			 defpregap= pktsize= mcn= textfile= cuefile=)
	track_options=(-audio -swab -data -mode2 -xa -xa1 -xa2 -xamix -cdi \
		       -isosize -pad padsize= -nopad -shorttrack -noshorttrack\
		       pregap= -preemp -nopreemp -copy -nocopy -scms tcsize= \
		       isrc= index=)
	# look if previous was either a file or a track option
	track_mode=0
	if [ $COMP_CWORD -gt 1 ]; then
		if [ -f "$prev" ]; then
			track_mode=1
		else
			for (( i=0; i < ${#track_options[@]}; i++ )); do
				if [[ "${track_options[i]}" == "$prev" ]]; then
					track_mode=1
					break
				fi
			done
		fi
	fi

	# files are always eligible completion
	_filedir
	# track options are always available
	COMPREPLY=( ${COMPREPLY[@]} $( compgen -W '${track_options[@]}' -- $cur ) )
	# general options are no more available after file or track option
	if [ $track_mode -eq 0 ]; then
		COMPREPLY=( ${COMPREPLY[@]} \
			    $( compgen -W '${generic_options[@]}' -- $cur ) )
	fi

}
[ -n "${have:-}" ] && complete -F _cdrecord cdrecord

# mkisofs(8) completion
#
have mkisofs &&
_mkisofs()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
		-@(o|abstract|biblio|check-session|copyright|log-file|root-info|prep-boot|*-list))
			_filedir
			return 0
			;;
		-*-charset)
			COMPREPLY=( $( mkisofs -input-charset help 2>&1 | \
					tail +3 | grep "^$cur") )
			return 0
			;;
		-uid)
			_uids
			return 0
			;;
		-gid)
			_gids
			return 0
			;;
	esac

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-abstract -A -allow-lowercase \
				-allow-multidot -biblio -cache-inodes \
				-no-cache-inodes -b -eltorito-alt-boot -B -G \
				-hard-disk-boot -no-emul-boot -no-boot \
				-boot-load-seg -boot-load-size \
				-boot-info-table -C -c -check-oldname \
				-check-session -copyright -d -D -dir-mode \
				-dvd-video -f -file-mode -gid -gui \
				-graft-points -hide -hide-list -hidden \
				-hidden-list -hide-joliet -hide-joliet-list \
				-hide-joliet-trans-tbl -hide-rr-moved \
				-input-charset -output-charset -iso-level -J \
				-joliet-long -jcharset -l -L -log-file -m \
				-exclude-list -max-iso9660-filenames -M -N \
				-new-dir-mode -nobak -no-bak -force-rr -no-rr \
				-no-split-symlink-components \
				-no-split-symlink-fields -o -pad -no-pad \
				-path-list -P -p -print-size -quiet -R -r \
				-relaxed-filenames -sort -split-output \
				-stream-media-size -stream-file-name -sysid -T\
				-table-name -ucs-level -udf -uid \
				-use-fileversion -U -no-iso-translate -V \
				-volset -volset-size -volset-seqno -v -x -z \
				-hfs -apple -map -magic -hfs-creator \
				-hfs-type -probe -no-desktop -mac-name \
				-boot-hfs-file -part -auto -cluster-size \
				-hide-hfs -hide-hfs-list -hfs-volid \
				-icon-position -root-info -prep-boot \
				-input-hfs-charset -output-hfs-charset \
				-hfs-unlock -hfs-bless -hfs-parms --cap \
				--netatalk --double --ethershare --ushare \
				--exchange --sgi --xinet --macbin --single \
				--dave --sfm --osx-double --osx-hfs' -- $cur ))
	else
		_filedir
	fi

}
[ -n "${have:-}" ] && complete -F _mkisofs mkisofs

# mc(1) completion
#
have mc &&
_mc()
{
	local cur prev

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	if [ "$prev" = "-e" -o "$prev" = "-v" ]; then
		_filedir
	else
		_filedir -d
	fi
}
[ "${have:-}" ] && complete -F _mc $filenames mc

# yum(8) completion
#
have yum && {
_yum()
{
	local cur prev special
	
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
		if [[ ${COMP_WORDS[i]} == @(install|update|upgrade|remove) ]]; then
			special=${COMP_WORDS[i]}
		fi
	done

	if [ -n "$special" ]; then
	    case $special in
		install)
		    COMPREPLY=( $( compgen -W '$( yum -C list | cut -d" " -f1 )' -- $cur ) )
		    return 0
		    ;;
		*)
		    _rpm_installed_packages
		    return 0
		    ;;
		esac
	fi

	case $cur in
	    --*)
		COMPREPLY=( $( compgen -W '--installroot --version --help' -- $cur ) )
		return 0
		;;
	    -*)
		COMPREPLY=( $( compgen -W '-c -e -d -y -t -R -C -h' -- $cur ) )
		return 0
		;;
	esac

	case $prev in
	    list)
		COMPREPLY=( $( compgen -W 'available updates installed extras' -- $cur ) )
		;;
	    clean)
		COMPREPLY=( $( compgen -W 'packages headers oldheaders all' -- $cur ) )
		;;
	    -c)
		_filedir
		;;
	    --installroot)
		_filedir -d
		;;
	    *)
		COMPREPLY=( $( compgen -W 'install update check-update upgrade remove list \
						search info provides clean groupinstall groupupdate \
						grouplist ' -- $cur ) )
		;;
	esac
}
[ -n "${have:-}" ] && complete -F _yum $filenames yum

# yum-arch(8) completion
#
_yum_arch()
{
    local cur
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    case "$cur" in
	-*)
	    COMPREPLY=( $( compgen -W '-d -v -vv -n -c -z -s -l -q' -- $cur ) )
	    ;;
	*)
	    _filedir -d
	    ;;
    esac

    return 0

}
complete -F _yum_arch $filenames yum-arch
}

# ImageMagick completion
#
have convert && {
_ImageMagick()
{
	local prev
	prev=${COMP_WORDS[COMP_CWORD-1]}

	case "$prev" in
		-channel)
			COMPREPLY=( $( compgen -W 'Red Green Blue Opacity \
				Matte Cyan Magenta Yellow Black' -- $cur ) )
			return 0
			;;
		-colormap)
			COMPREPLY=( $( compgen -W 'shared private' -- $cur ) )
			return 0
			;;
		-colorspace)
			COMPREPLY=( $( compgen -W 'GRAY OHTA RGB Transparent \
				XYZ YCbCr YIQ YPbPr YUV CMYK' -- $cur ) )
			return 0
			;;
		-compose)
			COMPREPLY=( $( compgen -W 'Over In Out Atop Xor Plus \
				Minus Add Subtract Difference Multiply Bumpmap\
				Copy CopyRed CopyGreen CopyBlue CopyOpacity' \
				-- $cur ) )
			return 0
			;;
		-compress)
			COMPREPLY=( $( compgen -W 'None BZip Fax Group4 JPEG \
				Lossless LZW RLE Zip' -- $cur ) )
			return 0
			;;
		-dispose)
			COMPREPLY=( $( compgen -W 'Undefined None Background \
						    Previous' -- $cur ) )
			return 0
			;;
		-encoding)
			COMPREPLY=( $( compgen -W 'AdobeCustom AdobeExpert \
				AdobeStandard AppleRoman BIG5 GB2312 Latin2 \
				None SJIScode Symbol Unicode Wansung' -- $cur))
			return 0
			;;
		-endian)
			COMPREPLY=( $( compgen -W 'MSB LSB' -- $cur ) )
			return 0
			;;
		-filter)
			COMPREPLY=( $( compgen -W 'Point Box Triangle Hermite \
				Hanning Hamming Blackman Gaussian Quadratic \
				Cubic Catrom Mitchell Lanczos Bessel Sinc' \
				-- $cur ) )
			return 0
			;;
		-format)
			COMPREPLY=( $( convert -list format | \
				    awk '/ [r-][w-][+-] / {print $1}' | \
				    tr -d '*' | tr [:upper:] [:lower:] | \
				    grep "^$cur" ) )
			return 0
			;;
		-gravity)
			COMPREPLY=( $( compgen -W 'Northwest North NorthEast \
				West Center East SouthWest South SouthEast' \
				-- $cur ) )
			return 0
			;;
		-intent)
			COMPREPLY=( $( compgen -W 'Absolute Perceptual \
					Relative Saturation' -- $cur ) )
			return 0
			;;
		-interlace)
			COMPREPLY=( $( compgen -W 'None Line Plane Partition' \
					-- $cur ) )
			return 0
			;;
		-limit)
			COMPREPLY=( $( compgen -W 'Disk File Map Memory' \
					-- $cur ) )
			return 0
			;;
		-list)
			COMPREPLY=( $( compgen -W 'Delegate Format Magic \
					Module Resource Type' -- $cur ) )
			return 0
			;;
		-map)
			COMPREPLY=( $( compgen -W 'best default gray red \
					green blue' -- $cur ) )
			_filedir
			return 0
			;;
		-noise)
			COMPREPLY=( $( compgen -W 'Uniform Gaussian \
					Multiplicative \
				Impulse Laplacian Poisson' -- $cur ) )
			return 0
			;;
		-preview)
			COMPREPLY=( $( compgen -W 'Rotate Shear Roll Hue \
					Saturation Brightness Gamma Spiff \
					Dull Grayscale Quantize Despeckle \
					ReduceNoise AddNoise Sharpen Blur \
					Treshold EdgeDetect Spread Shade \
					Raise Segment Solarize Swirl Implode \
					Wave OilPaint CharcoalDrawing JPEG' \
					-- $cur ) )
			return 0
			;;
		-@(mask|profile|texture|tile|write))
			_filedir
			return 0
			;;
		-type)
			COMPREPLY=( $( compgen -W 'Bilevel Grayscale Palette \
					PaletteMatte TrueColor TrueColorMatte \
					ColorSeparation ColorSeparationlMatte \
					Optimize' -- $cur ) )
			return 0
			;;
		-units)
			COMPREPLY=( $( compgen -W 'Undefined PixelsPerInch \
					PixelsPerCentimeter' -- $cur ) )
			return 0
			;;
		-virtual-pixel)
			COMPREPLY=( $( compgen -W 'Constant Edge mirror tile' \
					-- $cur ) )
			return 0
			;;
		-visual)
			COMPREPLY=( $( compgen -W 'StaticGray GrayScale \
					StaticColor PseudoColor TrueColor \
					DirectColor defaut visualid' -- $cur ))
			return 0
			;;
	esac
}

_convert()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_ImageMagick

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-adjoin -affine -antialias -append \
			-authenticate -average -background -black-threshold \
			-blue-primary -blur -border -bordercolor -channel \
			-charcoal -chop -clip -coalesce -colorize -colors \
			-colorspace -comment -compress -contrast -convolve \
			-crop -cycle -debug -deconstruct -delay -density \
			-depth -despeckle -display -dispose -dither -draw \
			-edge -emboss -encoding -endian -enhance -equalize \
			-extract -fill -filter -flatten -flip -flop -font \
			-frame -fuzz -gamma -gaussian -geometry \
			-green-primary -gravity -help -implode -intent \
			-interlace -label -lat -level -limit -list -log -loop \
			-map -mask -matte -median -modulate -monochrome \
			-morph -mosaic -negate -noop -noise -normalize \
			-opaque -ordered-dither -page -paint -ping -pointsize \
			-preview -profile -quality -raise -random-threshold \
			-region -raise -red-primary -render -resize -resample \
			-roll -rotate -sample -sampling-factor -scale -scene \
			-seed -segment -shade -sharpen -shave -shear -size \
			-solarize -spread -stroke -strokewidth -swirl \
			-texture -threshold -thumbnail -tile -transform \
			-transparent -treedepth -trim -type -undercolor \
			-units -unsharp -verbose -version -view \
			-virtual-pixel -wave -white-point -white-threshold \
			-write' -- $cur ) )
	elif [[ "$cur" == +* ]]; then
		COMPREPLY=( $( compgen -W '+adjoin +append +compress \
			+contrast +debug +dither +endian +gamma +label +map \
			+mask +matte +negate +noise +page +raise +render \
			+write' -- $cur ) ) 
	else
		_filedir
	fi
}
complete -F _convert $filenames convert

_mogrify()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_ImageMagick

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-affine -antialias -authenticate \
			-background -black-threshold -blue-primary -blur \
			-border -bordercolor -channel -charcoal -chop \
			-colorize -colors -colorspace -comment -compress \
			-contrast -convolve -crop -cycle -debug -delay \
			-density -depth -despeckle -display -dispose -dither \
			-draw -edge -emboss -encoding -endian -enhance \
			-equalize -extract -fill -filter -flip -flop -font \
			-format -frame -fuzz -gamma -gaussian -geometry \
			-green-primary -implode -interlace -help -label -lat \
			-level -limit -list -log -loop -map -mask -matte \
			-median -modulate -monochrome -negate -noop \
			-normalize -opaque -page -paint -fill -ordered-dither \
			-pointsize -profile -quality -raise -random-threshold \
			-red-primary -region -resample -resize -roll -rotate \
			-sample -sampling-factor -scale -scene -seed -segment \
			-shade -sharpen -shear -size -solarize -spread \
			-stroke -strokewidth -swirl -texture -threshold \
			-thumbnail -tile -transform -transparent -treedepth \
			-trim -type -undercolor -units -unsharp -verbose \
			-version -view -virtual-pixel -wave -white-point \
			-white-threshold' -- $cur ) )
	elif [[ "$cur" == +* ]]; then
		COMPREPLY=( $( compgen -W '+compress +contrast +debug +dither \
			+endian +gamma +label +map +mask +matte +negate +page \
			+raise' -- $cur ) ) 
	else
		_filedir
	fi
}
complete -F _mogrify $filenames mogrify

_display()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_ImageMagick

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-authenticate -backdrop -border \
			-colormap -colors -colorspace -comment -compress \
			-contrast -crop -debug -delay -density -depth \
			-despeckle -display -dispose -dither -edge -endian \
			-enhance -extract -filter -flip -flop -frame -gamma \
			-geometry -help -immutable -interlace -label -limit \
			-log -map -matte -monochrome -negate -noop -page \
			-quality -raise -remote -roll -rotate -sample \
			-sampling-factor -scene -segment -sharpen -size \
			-texture -treedepth -trim -update -verbose -version \
			-virtual-pixel -window -window_group -write' -- $cur))
	elif [[ "$cur" == +* ]]; then
		COMPREPLY=( $( compgen -W '+compress +contrast +debug +dither \
			+endian +gamma +label +map +matte +negate +page \
			+raise +write' -- $cur ) ) 
	else
		_filedir
	fi
}
complete -F _display $filenames display

_animate()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_ImageMagick

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-authenticate -backdrop -colormap \
			-colors -colorspace -crop -debug -delay -density \
			-depth -display -dither -extract -gamma -geometry \
			-help -interlace -limit -log -matte -map -monochrome \
			-noop -pause -remote -rotate -sampling-factor -scene \
			-size -treedepth -trim -verbose -version -visual \
			-virtual-pixel -window' -- $cur ) )
	elif [[ "$cur" == +* ]]; then
		COMPREPLY=( $( compgen -W '+debug +dither +gamma +map +matte' -- $cur ) ) 
	else
		_filedir
	fi
}
complete -F _animate $filenames animate

_identify()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_ImageMagick

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-authenticate -debug -density \
			-depth -extract -format -help -interlace -limit -list \
			-log -size -sampling-factor -verbose -version \
			-virtual-pixel' -- $cur ) )
	elif [[ "$cur" == +* ]]; then
		COMPREPLY=( $( compgen -W '+debug ' -- $cur ) ) 
	else
		_filedir
	fi
}
complete -F _identify $filenames identify

_montage()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_ImageMagick

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-adjoin -affine -authenticate \
			-blue-primary -blur -colors -colorspace -comment \
			-compose -compress -crop -debug -density -depth \
			-display -dispose -dither -draw -encoding -endian \
			-extract -fill -filter -flip -flop -frame -gamma \
			-geometry -gravity -green-primary -interlace -help \
			-label -limit -log -matte -mode -monochrome -noop \
			-page -pointsize -quality -red-primary -resize \
			-rotate -sampling-factor -scene -shadow -size \
			-stroke -texture -thumbnail -tile -transform \
			-transparent -treedepth -trim -type -verbose \
			-version -virtual-pixel -white-point' -- $cur ) )
	elif [[ "$cur" == +* ]]; then
		COMPREPLY=( $( compgen -W '+adjoin +compress +debug +dither \
			+endian +gamma +label +matte +page' -- $cur ) ) 
	else
		_filedir
	fi
}
complete -F _montage $filenames montage

_composite()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_ImageMagick

	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W '-affine -authenticate \
			-blue-primary -colors -colorspace -comment -compose \
			-compress -debug -density -depth -displace -display \
			-dispose -dissolve -dither -encoding -endian -extract \
			-filter -font -geometry -gravity -green-primary -help \
			-interlace -label -limit -log -matte -monochrome \
			-negate -page -profile -quality -red-primary -rotate \
			-resize -sampling-factor -scene -sharpen -size \
			-stegano -stereo -thumbnail -tile -transform \
			-treedepth -type -units -unsharp -verbose -version \
			-virtual-pixel -watermark -white-point -write' \
			-- $cur ) )
	elif [[ "$cur" == +* ]]; then
		COMPREPLY=( $( compgen -W '+compress +debug +dither +endian +label \
			+matte +negate +page +write' -- $cur ) ) 
	else
		_filedir
	fi
}
complete -F _composite $filenames composite
}

# dd(1) completion
#
have dd &&
_dd()
{
         local cur

         COMPREPLY=()
         cur=${COMP_WORDS[COMP_CWORD]}

         case "$cur" in
         if=*|of=*)
                 cur=${cur#*=}
                 _filedir
                 return 0
                 ;;
         conv=*)
                 cur=${cur#*=}
                 COMPREPLY=( $( compgen -W 'ascii ebcdic ibm block unblock \
                                lcase notrunc ucase swab noerror sync' \
                                -- $cur ) )
                 return 0
                 ;;
         esac

         _expand || return 0

         COMPREPLY=( $( compgen -W '--help --version' -- $cur ) \
                     $( compgen -W 'bs cbs conv count ibs if obs of seek 
skip' -S '=' -- $cur ) )
}
[ "${have:-}" ] && complete -F _dd $nospace dd

# CUPS cancel(1) completion
#
have cancel &&
_cancel()
{
	local cur

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=( $( lpstat | cut -d' ' -f1 | grep "^$cur" ) )
}
[ "${have:-}" ] && complete -F _cancel $filenames cancel

_filedir_xspec()
{
	local IFS cur xspec

	IFS=$'\t\n'
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	_expand || return 0

	# get first exclusion compspec that matches this command
	xspec=$( grep '^complete ' $BASH_COMPLETION | \
		  sed -ne '/ '${1##*/}'/{p;q;}' )
	# prune to leave nothing but the -X spec
	xspec=${xspec#*-X }
	xspec=${xspec%% *}

	COMPREPLY=( $( eval compgen -f -X "$xspec" -- \
		    \"${cur#[\`\"\']}\" 2>/dev/null ) \
		    $( compgen -d -- $cur ) )
}
list=( $( sed -ne '/^# START exclude/,/^# FINISH exclude/p' \
	  $BASH_COMPLETION | \
	# read exclusion compspecs
	(
	while read line
	do
		# ignore compspecs that are commented out
		if [ "${line#\#}" != "$line" ]; then continue; fi
		line=${line%# START exclude*}
		line=${line%# FINISH exclude*}
		line=${line##*\'}
		list=( ${list[@]:-} $line )
	done
	echo ${list[@]}
	)
     ) )
# remove previous compspecs
if [ ${#list[@]} -gt 0 ]; then
    eval complete -r ${list[@]}
    # install new compspecs
    eval complete -F _filedir_xspec $filenames ${list[@]}
fi
unset list

# source completion directory definitions
if [ -d $BASH_COMPLETION_DIR -a -r $BASH_COMPLETION_DIR -a \
     -x $BASH_COMPLETION_DIR ]; then
	for i in $BASH_COMPLETION_DIR/*; do
		[[ ${i##*/} != @(*~|*.bak|*.swp|\#*\#|*.dpkg*|.rpm*) ]] &&
			[ -f $i -a -r $i ] && . $i
	done
fi
unset i

# source user completion file
[ $BASH_COMPLETION != ~/.bash_completion -a -r ~/.bash_completion ] \
	&& . ~/.bash_completion
unset -f have
unset UNAME RELEASE default dirnames filenames nospace bashdefault plusdirs

###  Local Variables:
###  mode: shell-script
###  End:
