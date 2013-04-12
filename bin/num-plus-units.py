#!/usr/bin/env python

import sys, os
import dp_utils

def main(argv):
    import getopt
    rounding = None
    honesty = False
    allow_fractions_p = True
    powers_of_two_p = False
    verify_p = False
    opt_string = "2iafv"
    opts, args = getopt.getopt(argv[1:], opt_string)
    # XXX @todo implement rounding and honesty.
    for o, v in opts:
        if o == '-i':
            # Integer
            allow_fractions_p = False;
            continue
        if o == '-f':
            # Float/fraction
            allow_fractions_p = True;
            continue
        if o == '-2':
            powers_of_two_p = True
            continue
        if o == '-a':
            # 0x0A --> 10;
            powers_of_two_p = False
            continue
        if o == '-v':
            verify_p = True
            continue
##         if o == '-f':
##             rounding = dp_utils.SIZE_PLUS_UNITS_FRAC
##             continue
##         if o == '-i':
##             rounding = dp_utils.SIZE_PLUS_UNITS_INT
##             continue
##         if o == '-e':
##             rounding = dp_utils.SIZE_PLUS_UNITS_EVEN
##             continue
##         if o == '-h':
##             honesty = True
##             continue
            
    for arg in args:
        n = dp_utils.numPlusUnits(arg, allow_fractions_p=allow_fractions_p,
                                  powers_of_two_p=powers_of_two_p)
        print n
        if verify_p:
            print dp_utils.numWithUnits(n, allow_fractions_p=allow_fractions_p,
                                        powers_of_two_p=powers_of_two_p)

if __name__ == "__main__":
    main(sys.argv)


