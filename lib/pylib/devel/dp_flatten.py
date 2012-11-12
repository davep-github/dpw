#!/usr/bin/env python
### Time-stamp: <08/07/31 23:40:56 davep>
#############################################################################
## @package 
##
import sys, os

class Flatten_Iterables_done(Exception):
    def __init__(self, *args, **kw_args):
        super(Flatten_Iterables_done, self).__init__(*args, **kw_args)


def iterable_p(obj):
    try:
        return iter(obj)
    except TypeError:
        return None
    
def try_iter():
    try:
        i2 = iter(2)
    except Exception, e:
        print "type(e):", type(e)
        print "Exception:", e

def inner_flatten_iterables(*iters):
    i = iterable_p(iters)
    if not i:
        raise Flatten_Iterables_done()
    working_list = []
    for x in i:
        i2 = iterable_p(x)
        if i2 == None:
            working_list.append(x)
        else:
            working_list.extend(inner_flatten_iterables(x))
    return working_list

def flatten_iterables(*iters):
    try:
        the_list_so_far = inner_flatten_iterables(*iters)
    except Flatten_Iterables_done:
        pass
    return the_list_so_far

print flatten_iterables((1,2,3))
