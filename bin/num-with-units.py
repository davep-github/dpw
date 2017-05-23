#!/usr/bin/env python

import sys, os
import dp_utils

def main(argv):
    import getopt
    opt_string = "2b"
    base10_p = True
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o[1:] in "2b":
            base10_p = False
            continue

    for arg in args:
        if arg == "2b":
            continue
        print dp_utils.numWithUnits(arg, base10_p)

if __name__ == "__main__":
    main(sys.argv)
