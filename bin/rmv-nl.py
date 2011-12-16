#!/usr/bin/env python

import os, sys, sre

def mv_nl(fname):
    m = sre.search("(.+)\sNomad", fname)
    if m:
        print ">%s< ==> [%s]**************" % (fname, m.group(1))
        print os.rename(fname, m.group(1))
    else:
        print "NOM>%s<" % fname

def mv_nls(dname=".", pat="*"):
    for fname in os.listdir(dname):
        mv_nl(fname)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        sys.argv += ["."]

    for dname in sys.argv[1:]:
        mv_nls(dname)
