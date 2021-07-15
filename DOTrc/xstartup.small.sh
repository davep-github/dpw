#!/bin/sh

# Uncomment the following two lines for normal desktop:
# unset SESSION_MANAGER
# exec /etc/X11/xinit/xinitrc

[ -x /etc/vnc/xstartup ] && source /etc/vnc/xstartup
xres="$HOME/.Xresources"
[ -r "${xres}" ] && xrdb "${xres}"
xmodmap=$HOME/.xmodmap
[ -r "${xmodmap}" ] && xmodmap "${xmodmap}"
xsetroot -solid grey
if cbprog=$(find-bin autocutsel xcutsel vncconfig)
then
    xit "$cbprog"
fi
x-terminal-emulator --geometry=80x24+10+10 -l --title="$VNCDESKTOP Desktop" &
x-window-manager &
