#!/usr/bin/env python

import sys, os

#
# Motivated by the desire to avoid shell mode fontification.  A large grep in
# a shell buffer with too many lines was being fontified because the output
# was in numbered grep match format: filename:number. Adding a prefix which
# didn't match the pattern prevented the agonizingly slow fontification
# process.

def main(argv):
    import getopt
    opt_string = "p"
    prefix = "> "
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        if o == '-p':
            prefix = v
            continue

    for arg in args:
        # Handle arg
        pass

    ## Add code to allow prefix to be a function, with one to do numbering.
    for line in sys.stdin:
        print "%s%s" % (prefix, line),
        
if __name__ == "__main__":
    main(sys.argv)

