#!/usr/bin/env python

import sys, os, re, string
import dp_io, dp_misc
opath = os.path

#
# Write this all in Python and then have the shell scripts use it.
#
#
doc = """Definitions:
p4 location -- //a/path/used/by/perforce
--
There may be crud following the location.
E.g. output of p4 opened:
//hw/ap_t132/diag/testgen/build_gpu_multiengine.pl#5 - edit default change (text+kox)

"""

LOCATION_ROOT = "//"

def sans_line_num(line):
    m = re.search("(^[^:]+)(:[0-9]*$)?", line)
    if m:
        return m.group(1)
    else:
        return None

def sans_p4_junk(line):
    m = re.search("(^[^#]+)(#.*$)?", line)
    if m:
        return m.group(1)
    else:
        return None

def reroot(line, sb, verify_p=False):
    line = sans_p4_junk(line)
    if not line:
        return
    sb = dp_misc.normpath_plus(sb)
    newp = line.replace(LOCATION_ROOT, sb)
    if verify_p:
        print >>sys.stderr, "verify_p not supported."
        sys.exit(3)
    return newp

def reroot_iterable(sb, istream=sys.stdin, verify_p=False):
    ret = []
    for line in istream:
        if line[-1] == '\n':
            line = line[:-1]
        ret.append(reroot(line, sb, verify_p=verify_p))
    return ret

def reroot_command(sb, args, istream=sys.stdin):
    if args:
        ret = reroot_iterable(sb, args)
    else:
        ret = reroot_iterable(sb, istream)
    for l in ret:
        print l

#
# I'm changing from this to using a flag file to identify the root.
# There are a few reasons for this:
# 1) It is VC agnostic
# 2) It can understand the concept of one sandbox 
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
    import argparse
    istream = sys.stdin

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--reroot",
                         dest="reroot_p",
                         action="store_true",
                         help="Reroot command line args OR stdin.")
    oparser.add_argument("--sb", "--sandbox",
                         dest="sandbox", default="",
                         type=str,
                         help="Specify sandbox name.")

    oparser.add_argument("rest_of_args", nargs="*")
    app_args = oparser.parse_args()

    if app_args.reroot_p:
        reroot_command(app_args.sandbox, app_args.rest_of_args, istream)

    
if __name__ == "__main__":
    main(sys.argv)

