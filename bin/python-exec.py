#!/usr/bin/env python

import sys, os
op = os.path

py_base = op.splitext(op.basename(sys.argv[0]))[0]
py_prog = py_base + ".py"

__import__(py_base)                     # Compiles .py?

# Run it.  We could have a convention that all programs have a function
# equivalent to "__main__", but we want to run with old stuff, too.
#!<@todo Probe for, say, __main__func__ and call that to speed things up?

os.execlp(py_prog, sys.argv[0] + ".py", *sys.argv[1:])

