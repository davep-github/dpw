#!/usr/bin/env python

import sys, os

def main(argv):
    import getopt
    terminator = "\n"
    opt_string = "zr"
    translator = os.path.realpath
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-z':
            # Handle opt
            # for, say, xargs -0
            terminator = "\000"
            continue
        if o == '-r':
            translator = os.path.relpath

    for fileName in args:
        rp = translator(fileName)
        print '%s%s' % (rp, terminator),

if __name__ == "__main__":
    main(sys.argv)


