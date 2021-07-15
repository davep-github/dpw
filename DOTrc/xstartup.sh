#!/bin/bash
# $Id: xstartup.sh,v 1.1 2013-05-20 20:51:21-04 dpanariti Exp dpanariti $
{
echo "============== $(date) =================="
vncconfig -iconified &
autocutsel -selection PRIMARY &

#: ${W_MANAGER:=/usr/bin/gnome-session}
: ${W_MANAGER:=openbox}

source $HOME/.bashrc
echo "PATH>$PATH<"

if  ! [ -x /usr/dt/bin/dtwm ]
then
# Linux
  xrdb $HOME/.Xresources
  \xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
  "${W_MANAGER}" & ###-cmd "FvwmCpp /home/dpanariti/.fvwm/.fvwm2rc" &
  #/usr/bin/gnome-session &
  #/usr/bin/startkde &
  #fvwm2 &
  #set path = ( $path "/home/utils/xfce-4.4.2/bin" ); /home/utils/xfce-4.4.2/bin/startxfce4 &
else
# sun
  xrdb $HOME/.Xresources
  xrdb -load glx
  \xterm  -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
  xsetroot -solid grey
  /usr/dt/bin/dtwm &
fi
echo "==== script done. ===="
} >> $HOME/log/vnc-xstartup.log 2>&1
