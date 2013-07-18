#!/usr/bin/env python

import sys, os
import dp_io

#
# Write this all in Python and then have the shell scripts use it.
#
#
doc = """Definitions:
p4 location -- //a/path/used/by/perforce
"""

def p4_sb_location_to_absolute(p4_loc, sandbox=None):
    """Convert a p4 location to absolute path. """
    # glob = subprocess.Popen(["global"] + argv[1:], stdout=subprocess.PIPE)
    if sandbox:
        sandbox = " " + sandbox
    else:
        sandbox = ""
    cmd = "me-expand-dest %s%s" % (p4_loc, sandbox)
    #print >>sys.stderr, "cmd>%s<" % (cmd,)
    return dp_io.bq(cmd, nuke_newline_p=True)

def p4_cl_sb_location_to_absolute(argv):
    loc = argv[0]
    if len(argv) > 1:
        sb = argv[1]
    else:
        sb = None
    return p4_sb_location_to_absolute(loc, sb)

def main(argv):
    import getopt
    opt_string = "a"
    opts, args = getopt.getopt(argv[1:], opt_string)
    all_args_processor = None
    for o, v in opts:
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        if o == '-a':
            all_args_processor = p4_cl_sb_location_to_absolute
            continue

    if all_args_processor:
        ret = all_args_processor(args)
        if ret:
            print ret
        else:
            print >>sys.stderr, "Nothing was returned."
    else:
        for arg in args:
            # Handle arg
            pass

if __name__ == "__main__":
    main(sys.argv)

