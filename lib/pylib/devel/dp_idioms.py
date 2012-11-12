#!/usr/bin/env python
# $Id: dp_idioms.py,v 1.1.1.1 2005/05/05 15:15:57 davep Exp $
#
# common idioms that I tend to do over and over
#

def some_printer(fmt, *args):
    if args:
        fmt = fmt % args
    # ...

    
def stringize_list(lst):
    return ['%s' % (x,) for x in lst]

