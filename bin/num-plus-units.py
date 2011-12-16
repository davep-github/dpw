#!/usr/bin/env python

import sys, os
import dp_utils

def main(argv):
    import getopt
    rounding = None
    honesty = False
    opt_string = "fieh"
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-f':
            rounding = dp_utils.SIZE_PLUS_UNITS_FRAC
            continue
        if o == '-i':
            rounding = dp_utils.SIZE_PLUS_UNITS_INT
            continue
        if o == '-e':
            rounding = dp_utils.SIZE_PLUS_UNITS_EVEN
            continue
        if o == '-h':
            honesty = True
            continue
            
    for arg in args:
        print dp_utils.sizePlusUnits(arg, rounding=rounding, honesty=honesty)

if __name__ == "__main__":
    main(sys.argv)


