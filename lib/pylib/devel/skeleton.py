!#/usr/bin/env python

import os, sys, getopt

class Globals:
    """Globals: hold global variables.
Prevents need for global statement to modify global vars"""
    def __init__(self):
        # set up defaults
        self.verbose = 0

globals = Globals()        

options, args = getopt.getopt(sys.argv[1:], 'vV:')

for o, v in options:
    # print 'o>%s<, v>%s<' % (o, v)
    if o == '-V':
        globals.verbose = eval(v)
	continue
    if o == '-v':
        globals.verbose = globals.verbose + 1
        continue
        

for arg in args:
