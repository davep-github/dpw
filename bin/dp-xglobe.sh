#!/bin/bash
set -x

maps=$HOME/etc/xglobe-maps

echo ">$*<" >> ~/tmp/dp-xglobe.log
#-grid
xglobe -pos "fixed 28.53 -81.36" -markers \
 -once \
 -markerfile /home/davep/xearth.markers \
 -term 75 -nice 20  -nolabel \
 -mapfile $maps/Day_lrg.bmp \
 -nightmapfile $maps/Night_le_lrg.bmp \
 $*
