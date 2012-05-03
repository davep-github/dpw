#!/usr/bin/env python

import sys, os

def glob_to_pcre(glob):
    """A standard shell glob to a pcre which recognizes the same files."""

    print "glob>%s<" % glob
    pcre = glob
    # A glob matches the entire name, so preceded with ^ and end with $
    # . --> \.
    # [range] is unchanged
    # * --> .*
    # ? --> .
    #
    # Since some formats may have extensions, we'll return a suggested prefix
    # and suffix along with the pcre.
    ret = ["^"]
    # fix dots.
    pcre = pcre.replace(".", "\\.")
    pcre = pcre.replace("*", ".*")
    pcre = pcre.replace("?", ".")
    ret.append(pcre)
    ret.append("$")
    return ret

def cl_glob_to_pcre(arg):
    p, r, s = glob_to_pcre(arg)
    print p + r + s

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
        cl_glob_to_pcre(arg)
        print 

    for f, close_p in files_to_read:
        while True:
            l = f.readline()
            if not l:
                break
            l = l[0:-1]
            cl_glob_to_pcre(l)
        if (close_p):
            f.close()

if __name__ == "__main__":
    main(sys.argv)

