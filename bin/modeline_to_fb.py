#!/usr/bin/env python

import os, sys, string, math

# mode line:
# Modeline  "1280x1024" DCF HR SH1 SH2 HFL VR SV1 SV2 VFL

# First, calculate the required pixclock rate. XFree86 uses megahertz whilst
# framebuffer devices uses picoseconds (Why, I don't know). Divide one million
# by DCF. For example, 1,000,000 / 110.0 = 9090.9091


# Now we need to calculate the horizontal timings. 

# left_margin = HFL - SH2 
# right_margin = SH1 - HR 
# hsync_len = SH2 - SH1 

# In our example, this would be: 

# left_margin = 1712 - 1512 = 200 
# right_margin = 1328 - 1280 = 48 
# hsync_len = 1512 - 1328 = 184 

# And now we need to calculate the vertical timings. 

# upper_margin = VFL - SV2 
# lower_margin = SV1 - VR 
# vsync_len = SV2 - SV1 

# For our example, this would be: 

# upper_margin = 1054 - 1028 = 26 
# lower_margin = 1025 - 1024 = 1 
# vsync_len = 1028 - 1025 = 3 

# Now we can use this information to set up the framebuffer for the desired
# mode. For example, for the matroxfb framebuffer, it requires:


# video=matrox:xres:<>,yres:<>,depth:<>,left:<>,right:<>,hslen:<>,upper:<>,lower:<>,vslen:<>
# append = "video=matrox:xres:1280,yres:1024,depth:32,left:200,right:48,\
#  hslen:184,upper:26,lower:0,vslen:3"

# read in xres yres dcf ... vfl
#

xres = int(sys.argv[1])
yres = int(sys.argv[2])
dcf = float(sys.argv[3])
hr = int(sys.argv[4])
sh1 = int(sys.argv[5])
sh2 = int(sys.argv[6])
hfl = int(sys.argv[7])
vr = int(sys.argv[8])
sv1 = int(sys.argv[9])
sv2 = int(sys.argv[10])
vfl = int(sys.argv[11])
color_depth = int(sys.argv[12])
extra = sys.argv[13]

pixclock = 1000000.0/dcf
left_margin = hfl - sh2
right_margin = sh1 - hr
hsync_len = sh2 - sh1

upper_margin = vfl - sv2
lower_margin = sv1 - vr
vsync_len = sv2 - sv1

print "video=%s:xres:%d,yres:%d,depth:%d,left:%d,right:%d,hslen:%d,upper:%d,lower:%d,vslen:%d%s" % (
    "vesafb", xres, yres, color_depth, left_margin,
    right_margin, hsync_len, upper_margin, lower_margin,
    vsync_len, extra)

