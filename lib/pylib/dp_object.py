#!/usr/bin/env python

import sys, os

class dp_object(object):
    def __init__(self, **kw_args):
        ## My standard initialization style:
        ## def __init__(self, x):
        ##     self.d_x = x
        for k, v in kw_args.items():
            setattr(self, "d_" + k, v)

    # We mainly provide functionality
    def or_default(self, v, name):
        if v is None:
            v = getattr(self, name)
        return v

    def or_d_default(self, v, name):
        return self.or_default(v, "d_" + name)

## def main(argv):
##     import getopt
##     opt_string = ""
##     opts, args = getopt.getopt(argv[1:], opt_string)
##     for o, v in opts:
##         #if o == '-<option-letter>':
##         #    # Handle opt
##         #    continue
##         pass

##     for arg in args:
##         # Handle arg
##         pass

## if __name__ == "__main__":
##     main(sys.argv)

