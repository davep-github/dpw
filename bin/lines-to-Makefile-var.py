#!/usr/bin/env python

import sys, os

def mk_Makefile_var(in_file_obj=sys.stdin, out_file_obj=sys.stdout):
    while True:
        l = in_file_obj.readline()
        if not l: break
        out_file_obj.write(" \\\n\t%s" % l[0:-1])
    
def main(args):
    args = args[1:]
    var_name = args[0]
    args = args[1:]
    sys.stdout.write("%s = " % var_name)
    if len(args) == 0:
        mk_Makefile_var(sys.stdin)
    else:
        for f in args:
            fobj = open(f, "r")
            mk_Makefile_var(fobj)
            fobj.close()
    print "\n# End of variable", var_name

if __name__ == "__main__":
    main(sys.argv)
