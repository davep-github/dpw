#!/usr/bin/env python

import sys, os
import dp_utils

def main(argv):
    import getopt
    opt_string = ""
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-<option-letter>':
            # Handle opt
            continue
    for arg in args:
        print dp_utils.sizeWithUnits(arg)

if __name__ == "__main__":
    main(sys.argv)


