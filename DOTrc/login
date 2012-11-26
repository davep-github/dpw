# .login file
# $Id: //hw/nv/env/.login#6 $

##echo "trace_l00"

if ($?prompt) then
    if (($OSTYPE == "Linux") || ($OSTYPE == "Win32")) then
        stty erase "^?" 
    else
        stty erase "^H" 
    endif
    stty intr "^C"
    stty kill "" 
endif

# stty werase "" 
if (`tty` == "/dev/console")  setenv LOGHOST console

if ($OSTYPE != "Win32") then
    setenv DESKSET_DIMENSION -3D
    setenv EXINIT "set ai sw=4 wm=5 | map #3 :e#"
    setenv OPENWINHOME /usr/openwin
    setenv GUIDEHOME /usr/local/guide
endif

if ($TERM == "dumb") then
    setenv TERM vt100
endif

##echo "trace_l10"
source ~/.show-path
##echo "trace_l20"
