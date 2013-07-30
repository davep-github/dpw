#!/usr/bin/env python

import sys, os
import random

def digits(num_digits=1, sep=""):
    ss = []
    for i in xrange(num_digits):
        r = random.Random().randrange(0, 15)
        ss.append("%x" % (r,))
    return sep.join(ss)

class c_constants(object):
    def __init__(self, num_items=8):
        self.d_num_items = num_items

    def __call__(self, num_constants, sep="\n"):
        ss = []
        for i in xrange(num_constants):
            ss.append("0x" + digits(self.d_num_items))
        return sep.join(ss)

def main(argv):
    import getopt
    prefix = ""
    generator = digits
    opt_string = "cC:"
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-c':
            generator = c_constants()
            continue
        if o == '-C':
            generator = c_constants(eval(o) / 4)
            continue

    for arg in args:
        n = eval(arg)
        print generator(n)
        print

if __name__ == "__main__":
    main(sys.argv)

