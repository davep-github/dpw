#!/usr/bin/env python

import sys, os, string
import filecmp

def find_dup_dirs(dir1, dir2):
    d = filecmp.dircmp(dir1, dir2)
    return d.common_dirs

def ls_dup_dirs(d1, d2, ls_opts="-dC"):
    dirs = find_dup_dirs(sys.argv[1], sys.argv[2])
    return os.popen("ls %s %s" % (ls_opts, string.join(dirs))).read()
    

if __name__ == "__main__":
    print ls_dup_dirs(sys.argv[1], sys.argv[2])
    sys.exit(0)
    
