#!/usr/bin/env python

import sys, os, sre

##reference# #!/bin/sh
##reference# # Parse command line.
##reference# # std_options has some "useful" options.
##reference# # Set to "" or "-" to get nothing.  It's an error to call dp-getopt+.sh with
##reference# # std_options unset.
##reference# std_options=""

##reference# # The real meat...
##reference# #e.g.: option_str="fv:"        # !!!!!!! You probably want to set this !!!!!!!
##reference# option_str="snhH"

##reference# : ${DP_SCREEN_LS_REPL:="\\0"}
##reference# : ${DP_LS_SCREEN_NUM_SCREENS_REPL:=
##reference# number_screens=""
##reference# sed_dash_n="n"
##reference# sed_slash_p="p"
##reference# source dp-getopt+.sh
##reference# # Loop over your options.
##reference# #eko "$@"
##reference# for i in "$@"; do
##reference#     #echo "i>$i<, 1>$1<"
##reference#     case "$1" in
##reference#         -n) number_screens=t; sed_dash_n=""; 
##reference#             DP_SCREEN_LS_REPL=$DP_LS_SCREEN_NUM_SCREENS_REPL;;
##reference#         -s) DP_SCREEN_LS_REPL="\\2";;
##reference#         -[Hh]) Usage 0;;
##reference#         # ...
##reference#         --) shift; break;;
##reference#         *) Usage 1 "Bad option>$1<
##reference# ";;
        
##reference#     esac
##reference#     shift
##reference# done        

##reference# screen -ls 2>/dev/null | \
##reference# sed -r$sed_dash_n 's/$DP_SCREEN_LS_REGEXP/'$DP_SCREEN_LS_REPL"/$sed_slash_p"

#============================================================================

DP_SCREEN_LS_REGEXP = "(\s+)(\d+\.\S+)(.*$)"

def emit_screen_names(re_mo, line):
    if re_mo:
        print re_mo.group(2)

def emit_screens(re_mo, line):
    if re_mo:
        print re_mo.group(0)

screen_num = 1
def emit_screens_numbered(re_mo, line):
    global screen_num
    if re_mo:
        print "%s) %s" % (screen_num, re_mo.group(0))
        screen_num += 1
    else:
        print line

def do_screens(fobj, emitter, regexp=DP_SCREEN_LS_REGEXP):
    while True:
        line = fobj.readline()
        if len(line) == 0:
            break
        m = sre.search(DP_SCREEN_LS_REGEXP, line)
        emitter(m, line)


def main(args, emit_screens):
    # WTF??? Can't see the (*&^(*!@%^-ing global definition of emit_screens ????
    emitter = emit_screens
    import getopt
    options, args = getopt.getopt(sys.argv[1:], 'sn')
    # print 'options>%s<' % options
    for o, v in options:
        #print 'o>%s<, v>%s<' % (o, v)
        if o == '-s':
            emitter = emit_screen_names
            continue
        if o == '-n':
            emitter = emit_screens_numbered
            continue
    fobj = os.popen("screen -ls")
    do_screens(fobj, emitter)
    fobj.close()

if __name__ == "__main__":
    main(sys.argv, emit_screens)
