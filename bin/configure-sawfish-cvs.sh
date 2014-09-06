#!/bin/bash
set -x
patch < wm-spec.jl.patch

./configure --with-readline --disable-capplet --disable-gnome-widgets --without-gdk-pixbuf --x-libraries=/usr/X11R6/lib --x-includes=/usr/X11R6/include --prefix=$HOME/yokel/sawmill-cvs
