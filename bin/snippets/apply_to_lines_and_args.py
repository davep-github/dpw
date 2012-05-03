#!/usr/bin/env python

import sys, os

def PROC(line):

def main(argv):
    import getopt
    opt_string = "f:s"
    files_to_read = []
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-s':
            files_to_read = files_to_read.append((sys.stdin, False))
            continue
        if o == '-f':
            # Handle opt
            files_to_read.append(open(v, "r"), True)
            continue

    for arg in args:
        # Handle arg
        PROC(arg)
        print 

    for f, close_p in files_to_read:
        while True:
            l = f.readline()
            if not l:
                break
            l = l[0:-1]
            PROC(l)
        if (close_p):
            f.close()

if __name__ == "__main__":
    main(sys.argv)

