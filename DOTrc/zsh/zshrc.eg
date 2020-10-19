########################################
#
# .zshrc: for interactive shells (zsh -i)
# Written by Deborah Pickett <debbiep@csse.monash.edu.au>
# with large wads taken from others.
#
########################################

# Since .zshrc is only run once per interactive shell, most of the 
# configuring of the login session gets done here.  A few of .zshenv's
# settings are overridden here in the knowledge that the user is now
# able to give commands to the shell.


####################
# zsh-related things

###
# Shell Options
# Only those options relating to interactive shells.  The others were
# done in .zshenv already.
# Ones in capitals are variations from the default ZSH behaviour.
setopt \
  alwayslastprompt \
  ALWAYSTOEND \
  NO_APPENDHISTORY \
  AUTOCD \
  autolist \
  NO_AUTOMENU \
  AUTONAMEDIRS \
  autoparamkeys \
  autoparamslash \
  AUTOPUSHD \
  autoremoveslash \
  AUTORESUME \
  banghist \
  beep \
  bgnice \
  BRACECCL \
  no_cdablevars \
  no_completealiases \
  COMPLETEINWORD \
  CORRECT \
  no_correctall \
  no_cshjunkiehistory \
  no_extendedhistory \
  NO_FLOWCONTROL \
  no_globcomplete \
  hashlistall \
  histbeep \
  HISTIGNOREDUPS \
  no_histignorespace \
  HISTNOSTORE \
  no_histverify \
  hup \
  IGNOREEOF \
  no_interactivecomments \
  no_kshoptionprint \
  listambiguous \
  NO_LISTBEEP \
  listtypes \
  LONGLISTJOBS \
  no_mailwarning \
  no_menucomplete \
  monitor \
  notify \
  no_overstrike \
  promptcr \
  PROMPTSUBST \
  no_recexact \
  no_rmstarsilent \
  no_singlelinezle \
  no_sunkeyboardhack \
  no_verbose \
  no_xtrace \
  zle
if zsh-version 3.0.6
then
  setopt \
    no_histnofunctions \
    no_histreduceblanks \
    no_promptbang \
    promptpercent \
    no_rmstarwait
fi
if zsh-version 3.1.4
then
  setopt \
    no_bashautolist \
    HISTEXPIREDUPSFIRST \
    no_histignorealldups \
    no_histsavenodups \
    no_incappendhistory \
    no_share_history
fi
if zsh-version 3.1.8
then
  setopt \
    checkjobs \
    no_dvorak \
    no_histallowclobber \
    no_histfindnodups \
    LISTPACKED \
    no_listrowsfirst
fi


###########
# Functions

# Trap on exit from shell
# Shouldn't be set as an autoloaded function because it applies to
# this shell only (and also we don't want this to be inherited by
# subshells unless they are interactive, in which case they'll be
# defining their own version of this function).
# Remove the file created by the precmd function for listing jobs, but
# only if we are using the old jobs-listing technique.  Newer zshs don't
# need to create this file.
if ! zsh-version 3.1.8
then
  TRAPEXIT ()
  {
    /bin/rm -f "/tmp/jobs$HOST$$"
  }
fi

# Construct functions for reading mail.  Go through the $mailpath
# environment variable and extract the file names of folders.
# Then create a function "+filename" where "filename" is the last part
# of the folder.  This is used in conjunction with the COMMAND compctl
# (below) and the _first completion widget function (autoloaded)
# so that I can just type +<tab> and see what folders have mail, then
# select one and press ENTER to read that folder.
# $mailpathfiles is a version of $mailpath without the "?you have mail"
# bits, so that the function match-mail has an easier time of processing
# it.
local mailpathpart= folder= filename=
mailpathfiles=( )
for mailpathpart in "$mailpath[@]"
do
  folder="${mailpathpart%%\?*}"
  filename="${folder##*/}"
  eval '+'"$filename"' () { elm -f '"$folder"' }'
  mailpathfiles=("$mailpathfiles[@]" "$folder")
done
# And plus just on its own means start elm with my default folder.
+ () { elm }

# termsupported function
# Define a useful function to determine if the current value of TERM
# is useful, or if it needs changing.  Used below.
termsupported ()
{
  # terminfo should have a file for this terminal type.
  if [[ -f "/usr/lib/terminfo/$TERM[1]/$TERM" ]]
  then
    # If it's there, success.
    return 0
  else
    # With termcap, we have a monolithic terminal type listing.
    if [[ -f /etc/termcap ]]
    then
      # This sed script joins continued \
      # lines and then checks to see if this terminal name is listed.
      if [[ "`sed -n \
        -e '/^$/d' \
        -e '/^#/d' \
        -e 'h' \
        -e 's/^\\([^:\\\\]*\\)[:\\\\].*\$/|\\1|/' \
        -e '/|'$1'|/p' \
        -e 'g' \
        -e ':detail' \
        -e '/\\$/{' \
        -e 'n' \
        -e 'b detail' \
        -e '}' \
        < /etc/termcap`" = "" ]]
      then
        # Nothing matches, fail.
        return 1
      else
        # Found a matching entry, succeed.
        return 0
      fi
    else
      # If neither terminal capabilities system was found, fail.
      return 1
    fi
  fi
}

# precmd function
# This function's primary job is to set all the prompt fields before the
# prompt is displayed.  This includes:
# - The last command's exit status (including whether it was ended
#   by a signal);
# - Goofey status (active status, quietness and number of messages waiting);
# - Messages enabled?  (mesg command);
# - Mail (which of my folders contain new mail);
# - ZFTP status (host and pwd of connected machine);
# - Suspended job listing.
precmd ()
{
  # Look at exit status of last command - attach appropriate signal
  # if it was a signal that caused it.  It's safest to do this first
  # before $?'s value gets screwed up.
  local exitstatus=$? 
  if [[ $exitstatus -ge 128 && $exitstatus -le (127+${#signals}) ]]
  then
    # Last process was killed by a signal.  Find out what it was from
    # the $signals environment variable.
    psvar[1]=" $signals[$exitstatus-127]"
  else
    psvar[1]= 
  fi
  
  # Check the cursor position - is it up against the left margin?
  # This can be kind of slow, so we only do it if a shell variable is
  # set (which it isn't by default - see below).
  if [[ ${+PROMPTCURSORPOS} -eq 1 ]]
  then
    # This function works on xterms and other assorted terminals
    # by querying the terminal for its cursor position.  It returns zero
    # if the cursor is in the leftmost position, nonzero otherwise.
    if ! report-cursor-position $PROMPTCURSORPOS
    then
      print "[no newline]"
    fi
  fi

  # Local variables I'll need below.
  local mesgstatus
  
  # Slow stuff . . examine the magical SECONDS variable to see if it's time.
  # The periodic function could have been used for this, but it has some
  # drawbacks, such as the fact that it is run after precmd rather than
  # before.  Also, with newer versions of zsh, some things (such as
  # examining the flags/times on files) can be done without a process
  # fork, and thus can be taken outside the periodic code and into the
  # once-every-prompt code.  Rolling my own in this way ensures that I get
  # exactly the behaviour that I want.  The period between running this
  # stuff is at least $PROMPTPERIOD seconds.
  if [[ ${+PROMPTPERIOD} -eq 1 && $PROMPTPERIOD -gt 0 && \
     ( ${+LASTPROMPTTIME} -eq 0 || \
     $(( $SECONDS - $LASTPROMPTTIME )) -gt $PROMPTPERIOD ) ]]
  then
    # Print a little marker that will be overwritten, so that I know the
    # previous command is finished and I can start typing.
    echo -n "...\r"
    
    # goofey prompt
    # See my .zshenv for a description of goofey.
    if [[ ${+USE_GOOFEY} -eq 1 ]]
    then
      # This shell function sets psvar[6] to my goofey status.
      goofey-prompt-check
    fi
    
    # Mail prompt
    # Only need to do this for versions of zsh that don't have the 
    # stat builtin.  This new command means that this check can be done
    # every prompt (below).
    if ! zsh-version 3.1.3
    then
      # newmail.pl is a perl script that checks the modification and
      # access times of the mail files.
      psvar[3]="`newmail.pl \"${mailpath[@]:-$MAIL}\"`"
      if [[ "$psvar[3]" != "" ]]
      then
        psvar[3]="m[$psvar[3]] $XTTITLEBETWEEN"
      fi
    fi
    
    # mesg status
    # Only need to do this for versions of zsh that don't have stat.
    if ! zsh-version 3.1.3
    then
      # mesg-status is a perl script that examines the mode of the
      # TTY, and returns y or n, as mesg would.  Just doing
      # `mesg` doesn't work because then the program is not checking
      # the tty but the pipe that zsh opened to grab mesg's output.
      # Redirecting the output of mesg to a file doesn't work either,
      # because at least one version of mesg checks its output tty
      # which would be directed to a file.
      mesgstatus=`mesg-status "$TTY"`
    fi
  
    # Remember this time so we can tell when the next period is up.
    LASTPROMPTTIME=$SECONDS
  fi
  
  # Get a list of suspended jobs to put in the command line.
  # Newer versions of zsh have an interface to the jobs list, saving a
  # forked process.
  if zsh-version 3.1.8
  then
    # Newfangled clever way.
    # The only downside to doing the process list this way is that the
    # current and previous jobs (%+ and %-) can't be determined, because
    # the zsh/parameter module doesn't allow magical access to those
    # variables in the job-handling C code of the zsh.
    psvar[4]=
    if [[ $#jobstates -gt 0 ]]
    then
      local thisjob
      local jobnums
      jobnums=( "${(k@)jobstates}" )
      for thisjob in "$jobnums[@]"
      do
        # We only care about jobs that are suspended.
        if [[ "$jobstates[$thisjob]" = suspended:* ]]
        then
          psvar[4]="$psvar[4]${jobtexts[$thisjob]%% *}:$thisjob "
        fi
      done
    fi
    if [[ $#psvar[4] -gt 0 ]]
    then
      # Strip off the last space character.
      psvar[4]="[${psvar[4][1,-2]}] $XTTITLEBETWEEN"
    fi
  else
    # Oldfangled kludgy way.
    # Have to use a temporary file because it's the only way
    # we can run the jobs builtin and set a variable within the current
    # shell - doing either of these in a subshell defeats the purpose.
    # The jobs command outputs to stderr.  Use the current hostname
    # and process ID to ensure that there's no problems even if
    # /tmp is mounted across filesystems (why would it be?).
    builtin jobs -s >! "/tmp/jobs$HOST$$"
    if [[ -s "/tmp/jobs$HOST$$" ]]
    then
      # There's at least one suspended job.  Glean the job numbers from
      # the file.  Surround the text with the relevant description and
      # proper number of spaces.
      psvar[4]="j`perl -ne \
        '/^\\[(\\d+)\\]\\s+([+-]?)\\s+(?:\\d+\\s+)?\\w+\\s+(\w*)/ and
          \$jobs .= "\$3:\$1\$2 ";
         END { chop \$jobs; print \"[\", \$jobs, \"]\\n\" if \$jobs; }
        ' < /tmp/jobs$HOST$$` $XTTITLEBETWEEN"
    else
      # No jobs - we can skip the subprocess.
      psvar[4]=
    fi
  fi
  
  # ZFTP status.  ZFTP is an ftp client built right in to zsh.  Very neat.
  local zftptype
  if [[ "$ZFTP_HOST" != "" ]]
  then
    # We're connected.
    # Note the type of connection (ASCII or binary)
    if [[ "$ZFTP_TYPE" = "A" ]]
    then
      zftptype=A
    else
      zftptype=B
    fi
    # Display slightly differently for anonymous connections.
    if [[ "$ZFTP_USER" = (anonymous|ftp) ]]
    then
      # Anonymous ftp, don't list a username.
      psvar[8]="`print -P \"f${zftptype}[%15>..>$ZFTP_HOST%>>:%20<..<$ZFTP_PWD%<<]\"` "
    else
      # non-Anon ftp, put a username in.
      psvar[8]="`print -P \"f${zftptype}[$ZFTP_USER@%15>..>$ZFTP_HOST%>>:%20<..<$ZFTP_PWD%<<]\"` "
    fi
  else
    # Not connected.
    psvar[8]=
  fi
  
  # Message status.
  # On versions of zsh without stat, we checked the status above, once
  # every $PROMPTPERIOD seconds.
  # On newer versions of zsh, we check the status here, before every
  # prompt.
  if zsh-version 3.1.3
  then
    # 18 represents the bits for writing by others and by group.
    # Different unices do this differently.
    local ttystat
    # Element 3 of the stat structure is the file's mode.  We use the
    # array interface rather than a subshell to save a fork, and we use
    # it rather than the associative array interface because 3.1.3
    # doesn't have them.
    stat -A ttystat "$TTY"
    if [[ $(( $ttystat[3] & 18 )) -ne 0 ]]
    then
      mesgstatus=y
    else
      mesgstatus=n
    fi
  fi
  if [[ "$mesgstatus" = "$ORIGMESG" ]]
  then
    psvar[7]=""
  else
    psvar[7]="M[$mesgstatus] $XTTITLEBETWEEN"
  fi
  
  # Mail status.  Check to see if any mail folders contain unread mail.
  # On older versions of zsh, this required a fork to a perl script, which
  # was kinda slow, so it appears above in the code that runs only every
  # $PROMPTPERIOD seconds.  Newer zsh has stat built in, so we now have
  # the luxury of checking mail every time.
  if zsh-version 3.1.3
  then
    local thismail
    local newmail
    local mailstat
    newmail=()
    mailstat=()
  
    # Look at each part of the $MAILPATH variable.
    for thismail in "${mailpath[@]-$MAIL}"
    do
      # Strip off the ?... leaving just the path name.
      thismail="${thismail%%\?*}"
      # Skip to next mail file if zero size or doesn't exist.
      [[ -s "$thismail" ]] || continue
      if [[ -d "$thismail" ]]
      then
        # A directory, need to check for new files recursively.
        # To do . . I don't keep mail like this, so not high priority.
      else
        # Not a directory, just check the stat times of the file.
        # I have new mail if the file exists and its modification time
        # is later than its read time.  I use stat rather than the
        # [[ -N file ]] switch because that performs an mtime >= atime
        # comparison, and one system I am on sets the mail spool file
        # with equal mtime and atime.  Using stat, we calculate a strict
        # greater-than comparison, avoiding that problem.
        # Element 10 is the modification time, element 9 is the access
        # time.
        stat -A mailstat "$thismail"
        if [[ $mailstat[10] -gt $mailstat[9] ]]
        then
          # Add the filename (strip leading path) to the list.
          newmail=("$newmail[@]" "${thismail##*/}")
        fi
      fi
    done
    if [[ ${#newmail} -gt 0 ]]
    then
      psvar[3]="m[$newmail] $XTTITLEBETWEEN"
    else
      psvar[3]=
    fi
  fi
  
  # Get ready to produce the prompt.
  # On xterms, print some information in the title bar while
  # shortening the command-line prompt.
  if [[ "$TERM" = xterm ]]
  then
    set-title "`print -P \"$XTTITLEPS1\"`"
  fi
  
  # Now return, letting zsh print the prompt.
}

# logging out
# if there is text after the command line, kill all goofeys
# (if I'm using goofey) and give it the text as a goof-out
# message.  Then exit the shell.  It isn't bulletproof, but it's good
# enough for my needs.
# This function is called if I really want to exit the shell.
reallyexit ()
{
  if [[ ${+USE_GOOFEY} -eq 1 && $# -gt 0 ]]
  then
    # Kill all goofeys.
    goofey -x all - "$@"
  fi
  # Kill the shell.
  kill -HUP $$
}
# Process the exceptions which allow logging out while still having
# attached jobs.
logout ()
{
  # This is weird . . $1 seems to contain "logout" because the "logout"
  # command has been aliased to "noglob logout" - and $0 is the noglob.
  # I can't believe that this is what is meant to happen.
  if [[ $1 = "logout" ]]
  then
    shift
  fi
  # lastlogout is needed because we may have set histignoredups
  # In zsh 3.1.8 we have the history array.
  if zsh-version 3.1.8
  then
    # If the checkjobs option is unset, just plain exit.  (This option
    # emerged in zsh 3.1.8.)
    if [[ ! -o checkjobs ]]
    then
      reallyexit ${1+"$@"}
    fi
    # Did I type logout twice in a row?  Note check for history number.
    if [[ $history[$#history] = (exit|(logout|lo)(|\ *)) 
     || $lastlogout = $#history ]]
    then
      reallyexit ${1+"$@"}
    fi
    # Did I type jobs, then logout?
    if [[ $history[$#history] = (j(|obs)(|\ *)) ]]
    then
      reallyexit ${1+"$@"}
    fi
    lastlogout=$#history
    # Emulate the code that protects against logout if I have
    # attached jobs.
    if [[ $#jobstates -gt 0 ]]
    then
      # The first listed state is good enough to be a hint of my job states.
      echo "You have ${jobstates[${${(k)jobstates}[1]}]%%:*} jobs."
      return
    fi
    # If we got here we're really exiting.
    reallyexit ${1+"$@"}
  else
    # Did I type logout twice in a row?  Note check for history number.
    if [[ `print -P '%h'` = "$lastlogout" || \
      `print -P '%h'` -gt 1 && \
      "`history -n -1 -1`" = (exit|(logout|lo)(|\ *)) ]]
    then
      reallyexit ${1+"$@"}
    fi
    # Did I type jobs, then logout?
    if [[ `print -P '%h'` -gt 1 && "`history -n -1 -1`" = (j(|obs)(|\ *)) ]]
    then
      reallyexit ${1+"$@"}
    fi
    # Remember this history number.
    lastlogout=`print -P '%h'`
    # Emulate the code that protects against logout if I have
    # attached jobs.
    builtin jobs -r >! /tmp/jobs$HOST$$
    if [[ -s /tmp/jobs$HOST$$ ]]
    then
      echo "You have running jobs."
      return
    fi
    builtin jobs -s >! /tmp/jobs$HOST$$
    if [[ -s /tmp/jobs$HOST$$ ]]
    then
      echo "You have suspended jobs."
      return
    fi
    # If we got here we're really exiting.
    reallyexit ${1+"$@"}
  fi
}

###
# Interactive shell environment

# For interactive shells, we can display text a page at a time.  Set
# READNULLCMD to the $PAGER variable (or, failing that, more).
READNULLCMD="${PAGER-more}"

# Set TERM to reflect terminal type properly.
if [[ ${+TERMSET} = 0 ]]
then
  # Remember we've done this so we need not do it again for subshells.
  export TERMSET=

  # Now check if this terminal is known on this machine.
  if ! termsupported $TERM
  then
    case $TERM in
      modem|con<->x<->)
        # vt100 with no automatic margins.
        TERM=vt100-nam
        # But fix up the screen size, since we aren't necessarily at 80x24.
        eval "`resize`"
        ;;
    esac
  fi
fi


#########################
# Command-line completion

# I disable these from version 3.1.7 onwards, as we now have snazzy
# function-based completion.  Who needs these old compctls now?
# 3.1.6 seems to be a transitional shell so I leave them all in
# for this version.

if ! zsh-version 3.1.7
then
  # disable completion.
  compctl -k '( )' pushln pwd
  
  # complete commands.
  compctl -c whence type which hash unhash
  
  # complete function names.
  compctl -F functions unfunction reload autoload
  
  # complete alias names.
  compctl -a unalias alias
  
  # complete builtin commands.
  compctl -B disable enable
  
  # complete arrays.
  compctl -A shift
  
  # complete variable names.
  compctl -v unset
  
  # complete as if command of its own.
  compctl -l '' eval command
  
  # complete jobs - insert a '%' before the job name.
  compctl -j -P '%' bg fg disown jobs wait
  
  # complete directories (symlinks resolved).
  compctl -g '*(-/)' mkdir
  
  # complete current directory files and commands, first argument only.
  compctl -x 'p[1]' -f -c -- source .
  
  # typeset, declare, export, local, integer, readonly: match variable
  # names by default.
  compctl -v -x 'R[-*f,^*]' -F \
   - 's[-][+]' -k '(L R Z f i l r t u x m)' \
   -- typeset declare local integer export readonly
  
  # getopts: match names, second parameter only.
  compctl -x 'p[2]' -v -- getopts
  
  # limit: match keywords, allow optional -h beforehand.
  compctl -x 'p[1],p[2] c[-1,-h]' \
    -k '(cputime filesize datasize stacksize coredumpsize resident
  memoryuse memorylocked descriptors openfiles vmemorysize)' \
    -- limit unlimit
  
  # ulimit: match option letters.  Complete the word 'unlimited' if started.
  compctl -x 'S[u]' -k '(unlimited)' \
    - 's[-]' -k '(a c d f l m n o p s t u H)' \
    -- ulimit
  
  # fc: Match options, expect command for editor after -c,
  # forbid mutually incompatible options.
  compctl -x 'R[-[ARWI],^*] s[-]' -k '(A R W I)' \
    - 'R[-[ARWI],^*]' -f \
    - 's[-e],c[-1,-e]' -c \
    - 'R[-[enlrdDfEm],^*] s[-]' -k '(e n l r d D f E m)' \
    - 's[-]' -k '(A R W I e n l r d D f E m)' \
    -- fc
  
  # r: much-reduced version of fc; now just does options.
  compctl -x 's[-]' -k '(n l r)' -- r
  
  # vared: match options, allow entry of prompts after -p and -r,
  # match variables by default.
  compctl -v -x 's[-p][-r],C[-1,-[pr]]' -k '( )' \
    - 's[-]' -k '(c p r)' \
    -- vared
  
  # echotc: match termcap entries, for first word.  Only works if
  # $TERMCAP is set, otherwise no completion.  match-echotc isn't
  # smart enough to seek out the /etc/termcap file itself.
  compctl -x 'p[1]' -K match-echotc -- echotc
  
  # print: after -R, no options allowed.  After -u, need number,
  # otherwise, prompt for options.
  compctl -x 'R[-*R,^*]' -k '( )' \
    - 's[-u]' -k '( )' \
    - 's[-]' -k '(R n r s l z p N D P o O i c u)' \
    -- print
  
  # read: Need number after -u, so disable completion, otherwise
  # present options after a -.
  compctl -v -x 's[-u]' -k '( )' \
    - 's[-]' -k '(r z p q A c l n e E k u)' \
    -- read
  
  # sched: if first word starts with a -, present waiting jobs (match-sched).
  # Otherwise, complete as if second command were the real command.
  compctl -c -x 'p[1] s[-]' -K match-sched \
    - 'p[1]' -k '( )' \
    - 'p[2,-1]' -l '' \
    -- sched
  
  # builtin: complete first word as builtin command, then treat as arguments to
  # that command.
  # doing: compctl -B -x 'p[2,-1]' -l '' -- builtin
  # might seem to (but doesn't) work, but the following does.
  compctl -x 'p[1]' -B - 'p[1,-1]' -l '' -- builtin
  
  # trap: complete commands for first argument, then signals.
  compctl -k signals -x 'p[1]' -c -- trap
  
  # cd, pushd: complete using directory glob if absolute or explicitly relative,
  # otherwise use cdmatch function and force no trailing space.
  compctl -K 'match-cd' -S '' -x 'S[/][~][./][../]' -g '*(-/)' -- cd pushd
  
  # uucombine: complete using function.
  compctl -K "match-uucombine" uucombine
  
  # telnet: complete hosts by default.  Complete options given a leading
  # "-", complete user names after -l (which might not be valid on a
  # remote machine, but what do we know?), files after -n, disable after
  # -e, -k and -X, and if this is the second argument after options
  # have been swallowed, use the function match-services to get TCP/IP
  # services from the /etc/services file.
  compctl -k hosts \
    -x 's[-l],c[-1,-l]' -u \
    - 's[-n],c[-1,-n]' -f \
    - 's[-e],s[-k],s[-X],C[-1,-[ekX]]' -k '()' \
    - 's[-]' -k '(8 E K L X a d e k l n r)' \
    - 'p[2,-1] C[-1,^-*] C[-2,^-[lnekX]]' -K 'match-services' \
    -- telnet
  
  # rlogin: very much the same as telnet.
  compctl -k hosts \
    -x 's[-l],c[-1,-l]' -u \
    - 's[-e],s[-k],C[-1,-[ek]]' -k '()' \
    - 's[-]' -k '(8 E K L d e k l x)' \
    -- rlogin
  
  # ls, dir: complete files, options (both - and -- kind), and option params.
  # This is for GNU ls.
  compctl -f \
    -x s'[--format]' -P '=' -k '(long verbose commas horizontal across vertical single-column)' \
    - s'[--sort]' -P '=' -k '(none time size extension)' \
    - s'[--time]' -P '=' -k '(atime ctime access use status)' \
    - s'[--width=][--tabsize=][--ignore=][-w][-T][-I],c[-1,-w][-1,-T][-1,-I]' \
      -k '( )' \
    - s'[--]' -S '' -k '(all\  escape\  directory\  inode\  kilobytes\  numeric-uid-gid\  no-group\  hide-control-chars\  reverse\  size\  width= tabsize= almost-all\  ignore-backups\  classify\  file-type\  full-time\  ignore= dereference\  literal\  quote-name\  no-color\  7bit\  8bit\  recursive\  sort= format= time= help\  version\ )' \
    - s'[-]' -k '(a b c d f g i k l m n o p q r s t u x A B C F G L N Q R S U X 1 w T I)' \
    -- ls dir
  
  # elm: mail users, but if -f or -i is given, complete files,
  # and if -f+ (or -f=) is given, complete folders in ~/Mail.
  # Also complete options after -.  This entry was butchered from
  # the one in the zsh man page and altered for elm.
  compctl -u -x 's[+] c[-1,-f],s[-f+],s[-f=]' -g '~/Mail/*(:t)' \
    - 's[-f],s[-i],C[-1,-[fi]]' -f \
    - 's[-]' -k '(a c d f h i k K m s t V v z)' -- elm
  
  # man: complete commands, otherwise complete by search of $MANPATH.
  # This is placed as an all-encompassing pattern at the end because
  # making it the default before the -x doesn't work.  (It becomes
  # '-c + (-K 'match-man' -x ...), not (-c + -K 'match-man') -x ...).
  # We also complete paths for -M (override manpath), commands for
  # -P (pager) and disable for -S (search sections).  After an explicit
  # number (which it helps to complete for you), these completion rules
  # assume a thorough search is needed and no longer uses the '-c' hashed
  # commands, relying entirely on what's really in the manpath.
  compctl -x 'S[1][2][3][4][5][6][7][8][9]' -k '(1 2 3 4 5 6 7 8 9)' \
    - 'R[[1-9nlo]|[1-9](|[a-z]),^*]' -K 'match-man' \
    - 's[-M],c[-1,-M]' -g '*(-/)' \
    - 's[-P],c[-1,-P]' -c \
    - 's[-S],s[-1,-S]' -k '( )' \
    - 's[-]' -k '(a d f h k t M P)' \
    - 'p[1,-1]' -c + -K 'match-man' \
    -- man
  
  # tar: complete tar files (only .tar or .tar.* format) after -f, disable
  # completion for certain options, let user choose directory with -C,
  # complete GNU tar long options beginning with --.  The match-taropts
  # function prompts for GNU tar options, ensures one of the seven
  # mandatory options is given in the first argument to tar, and enforces
  # spaces after options that take an argument (this is required by GNU
  # tar and also makes filename completion possible for the -f option).
  # Note that the -[0-7][lmh] options are not completed, but they're
  # hardly ever used.
  compctl -f \
    -x 'C[-1,-*f],p[2] C[-1,*f],c[-1,--file]' -g '*.tar(|.*)' + -g '*(-/)' \
    - 'C[-1,-*[bLN]],p[2] C[-1,*[bLN]],c[-1,--block-size][-1,tape-length][-1,--after-date][-1,--newer]' -k '( )' \
    - 'C[-1,-*C],p[2] C[-1,*C],c[-1,directory]' -g '*(-/)' \
    - 'C[-1,-*[FgKTV]],p[2] C[-1,*[FgKTV]],c[-1,--info-script][-1,--new-volume-script][-1,--starting-file][-1,--files-from][-1,--label][-1,--exclude]' -f \
    - 's[--]' -k '(catenate concatenate create diff compare delete append list update extract get atime-preserve block-size read-full-blocks directory checkpoint file force-local info-script new-volume-script incremental dereference ignore-zeros ignore-failed-read keep-old-files starting-file one-file-system tape-length modification-time multi-volume after-date newer old-archive portability to-stdout same-permissions preserve-permissions absolute-paths preserve record-number remove-files same-order preserve-order same-owner sparse files-from null totals verbose label version interactive confirmation verify exclude exclude-from compress uncompress gzip ungzip use-compress-program block-compress)' \
    - 's[-],p[1]' -S '' -K 'match-taropts' \
    -- tar
  
  # compctl: complete using command names (and + ) by default, then
  # [1] After --, complete command names *only*;
  # [2] Between -x and --, just after -x or -, complete match characters
  #     (And add a '[' as a prompt for more);
  # [3] Match functions with -K;
  # [4] Arrays with -k;
  # [5] commands with -l;
  # [6] Disable completion on -X, -P, -S, -g, -s (all for one argument)
  #     and -H for two arguments.
  # [7] complete option letters when given a -.
  # This isn't as robust as it could be but it is as good as can be done
  # cleanly without adding several more cases.
  compctl -c -k '( + )' -x 'R[--,^*]' -c \
    - 'r[-x,--] s[-x],r[-x,--] c[-1,-x][-1,-]' -k '( s S p c C w W n N m r R )' -S '[' \
    - 's[-K],c[-1,-K]' -F \
    - 's[-k],c[-1,-k]' -A \
    - 's[-l],c[-1,-l]' -c \
    - 's[-X][-P][-S][-g][-s][-H],C[-1,-[XPSgsH]],C[-1,-H?*],c[-2,-H]' -k '( )' \
    - 's[-]' -k '( - c f q o v b C D A I F p E j B a R G u d e r z N O Z n k X K P S g s H l x )' \
    -- compctl
  
  # xsetroot: complete options, bitmaps, and colour names.
  # This version stolen from the zsh distribution and altered so that it
  # works.  See match-Xcolours for some truly weird parsing of the
  # rgb.txt file to ensure spaces are correctly handled.
  compctl -P '-' -k '(help default display cursor cursor_name bitmap mod fg foreground bg background grey gray rv reverse solid name)' \
    -x 'c[-1,-display]' -k hosts -S ':0.0' \
    - 'c[-1,-cursor][-2,-cursor][-1,-bitmap]' -f \
    - 'c[-1,-cursor_name]' -K 'match-Xcursor' \
    - 'C[-1,-(solid|fg|bg)]' -K 'match-Xcolours' \
    -- xsetroot
  
  # xhost: complete host names (set below in $hosts), even if after a + or -.
  compctl -k hosts -x 's[-][+]' -k hosts -- xhost
  
  # goofey: complete options after -, some other extended options in
  # certain cases, some hosts in some cases, otherwise goofey users from
  # the goofeywatch array which contains my goofey watch.
  # See .zshenv for an explanation of goofey
  compctl \
    -x 's[-a]' -k '(- +)' \
    - 's[-Q]' -k '(- + '\\!')' \
    - 'c[-1,-x]' -k "(all other)" + -k hosts \
    - 'c[-1,-d]' -k hosts \
    - 's[-r]' -k '(u q s f c wipe)' \
    - 's[-rc],s[-rf],s[-rs],s[-s],s[-w],s[-W],s[-l],s[-lt],s[-L],s[-Lt],s[-lc],s[-Lc],s[-R],C[-1,-([swWlLR]|[Ll][tc]|r[cfs])]' -K match-goofeyusers -S',' -q \
    - 's[-]' -k '( v N s Q x d dq d- dc r w W l lq lt lc L Lt f F h n j a A R S P E)' \
    -- goofey
  
  # Commands: if in first word, and line starts with a +, complete
  # functions beginning with "+" depending on which folders have mail in
  # them.  (These functions are defined above as shortcuts for "elm -f
  # somefolder".) If that fails, match commands as normal.
  compctl -C -c -x "S[+]" -K "match-mail" + -c
fi

# New! improved! zsh completion system, seems to be present from version
# 3.1.6 in my setup, but not (ahem) completely, so things may behave a
# little weird in 3.1.6.
if zsh-version 3.1.6
then
  compinit
  # zsh 3.1.7 uses zstyle instead of compconf.
  if zsh-version 3.1.7
  then
    # Turn on the completer, with approximation allowing two errors.
    # First try regular completions, then permit ignored matches too,
    # then approximation (but only after listing corrections first).
    zstyle ':completion:*' completer _complete _ignored _list _approximate
    zstyle ':completion:*:approximate:*' max-errors 2 numeric

    # Be verbose.
    zstyle ':completion:*' verbose 1

    # Group completions according to tags.
    zstyle ':completion:*:descriptions' format '%UCompleting %d:%u'
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' group-order ''

    # List unread mail folders before read mail folders with +folder
    # mail shortcup completion.  (See my _first function.)
    zstyle ':completion:*:mail-shortcuts:*' tag-order unread-mail-folders

    # Usernames and hosts
    zstyle ':completion:*' users-hosts `\
      [[ -f ~/.hosts ]] &&
        sed -n '/ /!d;s/^\([^ ]*\) *\([^ ]*\)/\2@\1/;p' < ~/.hosts;
      [[ -f ~/.rhosts ]] &&
        sed -n '/ /!s/$/ '$LOGNAME'/;s/^\([^ ]*\) *\([^ ]*\)/\2@\1/;p' < ~/.rhosts`
    zstyle ':completion:*' hosts `\
      [[ -f ~/.hosts ]] &&
        sed 's/ .*$//' < ~/.hosts;
      [[ -f ~/.rhosts ]] &&
        sed 's/ .*$//' < ~/.rhosts`
  else
    # Old-style completion configuration without styles.
    compconf completer=_complete
  fi
fi


#########
# Modules

# Module prefix changed in 3.1.7
ZSHMODPREFIX=""
if zsh-version 3.1.7
then
  ZSHMODPREFIX="zsh/"
fi

# Load any modules that I am likely to want to use.
if zsh-version 3.1.3
then
  # For checking of message status.
  zmodload -i ${ZSHMODPREFIX}stat
fi
if zsh-version 3.1.6
then
  # Because every shell should have a built-in FTP client
  zmodload -i ${ZSHMODPREFIX}zftp
  zfinit
  if zsh-version 3.1.7
  then
    # Don't mess with my xterm title bar.
    zstyle ':zftp:*' titlebar no
  fi
fi
if zsh-version 3.1.8
then
  # For checking job return status.
  zmodload -i ${ZSHMODPREFIX}parameter
fi


###############################
# The zsh Prompt From Hell (tm)

# This doesn't use the fancy new prompt theme system.  Something for
# later, perhaps.

# A few escape codes to print in each prompt
if [[ "$TERM" = con<->x<-> ]]
then
  # This is a linux console; make sure mode is stable when we get
  # a prompt by putting this text at the front of it.
  # These codes do:
  #   ^[^O        - ensure we're in graphics mode 0, fixes up
  #                 meta-bit problem after catting a binary file.
  #   ^[[m        - ANSI escape sequence to turn off attributes.
  #   ^[[?25h     - DEC vt100 private escape sequence to turn cursor on.
  #   ^[[?1l      - DEC vt100 private escape sequence to turn application
  #                 cursor keys off.
  TERMRESET='[m[?25h[?1l'
  # Escape sequence to set the half-bright attribute.  Part of the vt100
  # specification but not honoured by many interpreters.  Linux consoles
  # do use it, though you have to use setterm to tell linux to use a
  # different colour (I do this down below).
  # I'd use DIM=`echotc mh` but in their infinite wisdom no one declared
  # a half-bright-off termcap entry to match it.  That's probably
  # because there isn't a sequence to turn off dim only.  The one here
  # is the closest, turning off dim and bold together.  Furrfu.
  DIM='[2m'
  UNDIM='[22m'
fi

# This prompt included in PS1 only in non-xterms.  For xterms, a
# slightly different version is included in the title bar.
# In slow motion:
#   %(2L.s[$SHLVL] .)
#     Print nothing unless this is a subshell, in which case print the
#     shell depth in the prompt.
#   %5v
#     Print the current effective Unix group name if it differs from
#     the one in the original (ancestor) shell.  Set below.
#   %{$DIM} and %{$UNDIM}
#     vt100 half-bright escape codes (see definitions above).
#   %4v
#     Suspended jobs (set by precmd function).
#   %3v
#     Unread mail folders (set by precmd function).
#   %6v
#     Current goofey status (set by goofey-prompt-check function).
#     (See .zshenv for the meaning of goofey.)
#   %7v
#     Current message status (set by precmd function).
if [[ "$TERM" = xterm ]]
then
  SUBPS1=''
else
  SUBPS1='%(2L.s[$SHLVL] .)%5v%{'"$DIM"'%}%4v%{'"$UNDIM"'%}%3v%6v%7v'
fi

# The prompt itself.
# Here's the annotated version:
#   $TERMRESET
#     A reset-terminal string (see above).
#   %B%m%b
#     Machine name in boldface.
#   %30<...<%~%<<
#     Present working directory, truncated to last 30 charcters.
#   %8v
#     Current ZFTP status (set in precmd)
#   %(?..%Ue[%?%v]%u )
#     Exit status, if it is not zero, plus the signal name that
#     killed the last command (if there was one).  If the exit
#     status was zero (i.e., no error), display nothing (in true Unix
#     tradition).
#   $SUBPS1
#     Blank in xterms, otherwise more prompt information (defined
#     above).
#   %B%#%b
#     A boldface percent symbol, which mutates to a hash symbol
#     if I'm running root (not that I do; it's safer to run root
#     with a different shell so I don't get comfortable using it
#     for things I should be doing as a mere user).
#   %E
#     Clear to end of line.
PS1='%{'"$TERMRESET"'%}%B%m%b %30<...<%~%<< %8v%(?..%Ue[%?%v]%u )'"$SUBPS1"'%B%#%b %E'

# Secondary prompt - print the three last shell constructs, preceded
# with "..." if there are four or more.
PS2='%(4_:... :)%3_ %B>%b'

# This is printed in an xterm's title bar.  Uses the PROMPT escape codes.
if [[ "$TERM" = xterm ]]
then
  # This is the extra text (spaces) that go between
  # items in an xterm's title bar.
  XTTITLEBETWEEN=' '

  # Some implementations of strftime(3) don't have the %Y or the %H
  # directives.  Let's try them and use some substitutes if they are
  # not available.
  # Test for years with centuries:
  if [[ "`print -P '%D{%Y}'`" = '%Y' ]]
  then
    # I can't believe that some software still doesn't handle
    # four-digit years.  But then,
    # I can't believe COBOL is still being used either.
    STRFTIMEYEAR='%y'
  else
    STRFTIMEYEAR='%Y'
  fi
  # Test for 24-hour clock:
  if [[ "`print -P '%D{%H}'`" = '%H' ]]
  then
    # Colon betwen hour and minute = 12-hour clock.
    STRFTIMEHOUR='%k:'
  else
    # Dot betwen hour and minute = 24-hour clock.
    STRFTIMEHOUR='%H.'
  fi

  # xterm title-bar status line: the stuff that isn't displayed on the
  # prompt line on xterms goes here instead.  Most of this is the same
  # as for $SUBPS1, excepting:
  #   $TERM$XTTITLECONS
  #     "xterm" if this is a normal xterm.  If this is the foreground
  #     command from my .xsession, XTTITLECONS contains additional text
  #     to remind me that if I log out of this console, I HUP my whole X
  #     session.
  #   $LOGNAME%5v@%m:%~
  #     username, group, machine name, current directory.
  #   tty%l
  #     The TTY this shell is attached to.
  #   %D{...}
  #     The current date and time, in a format we've established
  #     above to display correctly on this machine.
  #   h[%h]
  #     The current history number.
  XTTITLEPS1='$TERM$XTTITLECONS '"$XTTITLEBETWEEN"\
"$LOGNAME"'%5v@%m:%~ '"$XTTITLEBETWEEN"\
'%(2L.s[$SHLVL] '"$XTTITLEBETWEEN"'.)%4v%3v%6v%7vtty%l '"$XTTITLEBETWEEN"\
'%D{'"$STRFTIMEYEAR"'-%m-%d '"$STRFTIMEHOUR"'%M} '"$XTTITLEBETWEEN"\
'h[%h]'
fi

# Remember our initial message status.  I used to care about this when I
# was using the talk program a lot, but now I leave it off pretty much
# all the time.  In any case, the code's here in case I care about it
# again in the future.  There's related stuff in the precmd function.
if [[ ${+ORIGMESG} -eq 0 ]]
then
  # First shell - remember the original status.
  if zsh-version 3.1.6
  then
    # Use the stat module to read the tty's group-write status.
    # the stat module was loaded above.  18 is the group-write
    # and other-write bits of the device's mode.  (Different
    # Unices do it different ways.)
    stat -A ttymode "$TTY"
    if [[ $(( $ttymode[3] & 18 )) -ne 0 ]]
    then
      export ORIGMESG=y
    else
      export ORIGMESG=n
    fi
    unset ttymode
  else
    # Use an external program to do it.
    export ORIGMESG=`mesg-status "$TTY"`.
  fi
fi

# See if our (effective) group has changed at all.  (For instance, we're
# in a subshell that is setgid.)  This kind of thing happens with the
# "gogroup" command available on one system I use (yoyo).
# I haven't put this in the precmd function because I don't expect
# my effective group to change over the life of the shell.  It can if
# I'm running with root privileges, but I deliberately don't use zsh for
# root in any case, because that encourages me to not use root for
# anything I don't have to use it for. 
if [[ "$ORIGGID" != "$EGID" ]]
then
  # Set for either normal prompt and xterm title bars.
  GNAME="`groupname $EGID`"
  if [[ "$TERM" = "xterm" ]]
  then
    psvar[5]=":$GNAME"
  else
    psvar[5]="g[$GNAME] "
  fi
else
  psvar[5]=
fi

# Set the period between calls to periodic functions (in seconds).
# Only set it if it isn't already set by me.  This construct also
# allows me to unset PERIOD completely without having a subshell
# set it back to the default again.  I find this important because the
# periodic function does some potentially slow stuff (which is even
# slower on a slow network).
if [[ ${+PERIODSET} -eq 0 ]]
then
  export PERIODSET=
  # We used to do some prompt checking stuff in the periodic function,
  # but it turned out to be easier to do this in precmd, manually
  # checking the time elapsed since the last time we ran periodic
  # stuff.  So PERIOD is unset, and we use another variable,
  # PROMPTPERIOD, to count the time between periodic stuff in the
  # prompt.
  unset PERIOD
  export PROMPTPERIOD=30
fi


############################
# Random bits to do with zsh

# Suffixes to ignore when completing
FIGNORE='~:.o:.swp:.bak'

# List completions if there are more than a screenful of them
LISTMAX=0

###
# Key Bindings
# set to emacs style
bindkey -e
# keypad keys
bindkey '\e[3~' delete-char
bindkey '\e[2~' overwrite-mode
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
# change some defaults
bindkey '^R' redisplay
bindkey '^Z' push-input            # "suspend" current line
#bindkey '\e/' which-command

###
# Aliases

# default switches
alias ls='command ls -AF'
alias mv='command mv -i'
alias cp='command cp -i'
alias jobs='builtin jobs -l'

# overriding/renaming commands
if whence vim >/dev/null 2>&1
then
  alias vi=vim
fi
# Drop-in replacements for rm.  They're buggy but they work well enough.
alias rm=trash-rm
alias unrm=trash-unrm
alias purge=trash-purge
# cdfunc has a neat little option where you could interactively select a
# directory on the directory stack to change to.  With nifty completion
# it isn't really necessary because you can type cd -<TAB> and see the
# directory stack that way.
#alias cd=cdfunc
if whence color_xterm >/dev/null 2>&1
then
  alias xterm='color_xterm -name xterm'
fi

# enhanced 'logout' for goofey -x - stuff (see the logout function)
alias logout='noglob logout'

# convenient abbreviations
alias se='. ${ZDOTDIR-$HOME}/.zshenv'
alias sc='. ${ZDOTDIR-$HOME}/.zshrc'
alias sl='. ${ZDOTDIR-$HOME}/.zlogin'
alias so='. ${ZDOTDIR-$HOME}/.zlogout'
alias eg='set | grep -i'
alias ag='alias | grep -i'
alias cg='compctl | grep -i'
alias hg='history 1- | grep -i'
alias c=clear
alias lo='noglob logout'

# goofey (when I'm using it)
if [[ ${+USE_GOOFEY} -eq 1 ]]
then
  # Aliases
  alias G='goofey'
  alias Gs='goofey -s'
  alias GS='goofey-S'                # zsh function
  alias Gsw='goofey -s watch'
  alias GSw='goofey-S watch'
  alias Go='goofey-reply -1'         # zsh function
  alias GO='goofey-reply'
  alias Gso='goofey-reply -1'
  alias GsO='goofey-reply'
  alias GSO='goofey-reply -f'
  alias GSo='goofey-reply -1f'
  alias Gx='goofey -x'
  alias Gxo='goofey -x other'
  alias Gxh='goofey; goofey -x other'
  alias Gw='goofey -w'
  alias GW='goofey -W'
  alias Gr='goofey -r'
  alias Grw='goofey -rw'
  alias Gr1='goofey -r1'
  alias Gru='goofey -ru'
  alias GR='goofey -R'
  alias Gl='goofey -l'
  alias GL='goofey -L'
  alias Gf='goofey -f'
  alias Ga-'goofey -a'
  alias Ga+='goofey -a+'
  alias Ga-='goofey -a-'
  alias GA='goofey -A'
  alias GQ='goofey -Q'
  alias GQ-='goofey -Q-'
  alias GQ+='goofey -Q+'
  alias Gfn='goofey -fn'
  alias Gfl='goofey -fl'
  alias Gin='goofey -rw | grep IN'
  alias Gout='goofey -rw | grep OUT'
  
  # Should we assume goofey is working by default?  (This suppresses
  # printing a simple 'G' in the prompt if there are no pending
  # messages, etc.)
  if [[ ${+ASSUME_GOOFEY} -eq 0 ]]
  then
    if [[ "$TERM" = xterm ]]
    then
      export ASSUME_GOOFEY=0;
    else
      export ASSUME_GOOFEY=1;
    fi
  fi
fi

# used when you press M-? on a command line
alias which-command='whence -a'

# zsh function tracing
alias ztrace='typeset -f -t'
alias zuntrace='typeset -f +t'


######################################################
# Other things to be done with every interactive login

###
# Some variables not actually used by the shell (and possibly not by me
# either - I think these are holdovers from compctl days).

# hosts - just strip them from ~/.rhosts and ~/.hosts
if [[ ${+hosts} -eq 0 ]]
then
  hosts=( $(sed 's/ .*$//' < ~/.rhosts < ~/.hosts) )
fi

# goofey watch cache - for use in the match-goofeyusers function and
# goofey compctl
if [[ ${+USE_GOOFEY} -eq 1 && -z "$goofeywatch" ]]
then
  # Split on spaces.
  goofeywatch=(`goofey -a watch`)
fi

###
# Terminal settings

# Make sure terminal is in nice mode
stty sane erase  intr 
# these ones might not mean anything on this machine.  Ignore any
# errors.
stty crterase crtkill crtbs pass8 2>/dev/null

# These things only need to be done once per interactive session, so
# check $INTSHELL and only run if not defined.
if [[ ${+INTSHELL} -eq 0 ]]
then
  # This is an interactive shell and we want all subshells
  # to note that they have an interactive shell behind them.
  # This differs from the option "interactive" because that
  # would be unset in noninteractive subshells this shell
  # invokes.  This is probably splitting hairs, since noninteractive
  # shells invoked by this shell probably won't be making
  # interactive "grandchild" shells, but a little paranoia can't
  # hurt.
  if [[ "$TERM" = con* ]]
  then
    # We are using a Linux console which presumably handles the vt100
    # ANSI colour extensions.
    # set underlining to be (bright) yellow
    # and half-bright to grey
    setterm -ulcolor bright yellow -hbcolor grey 2>/dev/null
  fi

  # Used to check the cursor position before printing the prompt.  Slow,
  # so don't want to set it again in a subshell if it's been explicitly
  # unset by the user.  (For one thing, it invokes stty twice for every
  # prompt - this is something you don't want to do unless the machine
  # can fork and exec quickly.)
  # The value is the number given to the stty command's "time"
  # parameter.
  # See functions precmd and report-cursor-position for more.
  # Disabled at the moment because it's a real pain on slow terminals.
  #export PROMPTCURSORPOS=2
fi

# We're running under an interactive shell now.
export INTSHELL=$$

###
# Perform a null command to set exit status to zero at first prompt
:

