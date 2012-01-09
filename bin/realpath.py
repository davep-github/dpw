#!/usr/bin/env python

import sys, os

argv = sys.argv[1:]

if argv[0] == "-r":
    translator = os.path.relpath
    argv = argv[1:]
else:
    translator = os.path.realpath

for a in argv:
    print translator(a)

sys.exit(0)

