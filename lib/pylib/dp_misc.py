#!/usr/bin/env python

#############################################################################
## @package
##
import sys

from dp_utils import *

print >> sys.stderr, "***"
print >> sys.stderr, "*** dp_misc is being deprecated."
print >> sys.stderr, "*** argv:"
print >> sys.stderr, "*** {}".format(", ".join(sys.argv))
print >> sys.stderr, "***"
########################################################################
if __name__ == "__main__":
    mkpath(sys.argv[1])
