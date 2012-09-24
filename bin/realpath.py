#!/usr/bin/env python

import sys, os

def relpath_translator(pathname, relpath):
    rp = os.path.relpath(pathname, relpath)
    return os.path.realpath(pathname)

def main(argv):
    import getopt
    terminator = "\n"
    opt_string = "zrR:"
    translator = os.path.realpath
    translator_args = []
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-z':
            # Handle opt
            # for, say, xargs -0
            terminator = "\000"
            continue
        if o == '-R':
            translator_args.append(v)
            translator = relpath_translator
            continue
        if o == '-r':
            translator = os.path.relpath
            continue

    for fileName in args:
        rp = translator(fileName, *translator_args)
        print '%s%s' % (rp, terminator),

if __name__ == "__main__":
    main(sys.argv)
