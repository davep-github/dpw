#!/usr/bin/env python

import sys, os
import dp_utils

def main(argv):
    import getopt
    opt_string = "2bh"
    powers_of_two_p = False
    base = 10
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o[1:] in "2b":
            powers_of_two_p = True
            base = 2
            continue
        if o[1:] in "h":
            powers_of_two_p = True
            base = 16
            continue

    for arg in args:
        if arg == "2b":
            continue
        print dp_utils.numWithUnits(arg, powers_of_two_p, base=base)

if __name__ == "__main__":
    main(sys.argv)
