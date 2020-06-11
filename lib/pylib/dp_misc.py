#!/usr/bin/env python

#############################################################################
## @package
##
import sys

from dp_utils import *

print("***", file=sys.stderr)
print("*** dp_misc is being deprecated.", file=sys.stderr)
print("*** argv:", file=sys.stderr)
print("*** {}".format(", ".join(sys.argv)), file=sys.stderr)
print("***", file=sys.stderr)
########################################################################
if __name__ == "__main__":
    mkpath(sys.argv[1])
