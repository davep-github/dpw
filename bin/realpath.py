#!/usr/bin/env python

import sys, os

for a in sys.argv[1:]:
    print os.path.realpath(a)

sys.exit(0)

