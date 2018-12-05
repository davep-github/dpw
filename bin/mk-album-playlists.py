#!/usr/bin/env python
#
# $Id: mk-album-playlists.py,v 1.9 2004/09/27 08:20:03 davep Exp $
#
import os, sys, getopt, re, string, dp_io, getopt

# pick one media lib
#import media_lib
if os.environ.get("DPY_MEDIA_LIB_NODEV"):
    import media_lib
else:
    import media_lib_dev                    # development lib
    media_lib = media_lib_dev

options, args = getopt.getopt(sys.argv[1:], 'vnfFdmpx')
for o, v in options:
    # print 'o>%s<, v>%s<' % (o, v)
    # @todo let media_lib parse common options...
    #       unknowns are returned to caller
    if o == '-v':
        media_lib.verbose = media_lib.verbose + 1
	continue
    if o == '-n':
        media_lib.no_execute = 1
	continue
    if o == '-x':
        media_lib.no_execute = 0
	continue
#     if o == '-f':
#         media_lib.fix_id3 = 1
# 	continue
    if o == '-F':
        media_lib.fix_file_names_p = 1
	continue
    if o == '-d':
        dp_io.debug_on()
        continue
#     if o == '-m':
#         media_lib.fix_id3_minimal = 1
#         media_lib.fix_id3 = 1
#         continue
    if o == '-p':
        media_lib.no_playlists_p = 1
        continue


media_lib.init()

if len(args) == 0:
    music_dirs = (media_lib.music_dir,)
else:
    music_dirs = args

for dir in music_dirs:
     media_lib.media_lib_process_mp3_tree(dir)

media_lib.print_status('\ndone.\n')

sys.exit(0)
