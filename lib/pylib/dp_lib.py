#!/usr/bin/env python
### Time-stamp: <08/07/25 18:57:28 davep>
#############################################################################
## @package 
##
import sys, os, types

def dp_exceptable_p(v):
    return issubclass(Exception, v) or type(v) == types.TypeType

