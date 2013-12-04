#!/usr/bin/env python
### Time-stamp: <13/12/04 16:06:16 dpanariti>
#############################################################################
## @package 
##
import sys, os, urllib, string
opath = os.path

def dotdot_ify_url(url, num_dotdots=0, dotdot_string="", debug=False):
    if not num_dotdots:
        if dotdot_string:
            num_dotdots = len(string.split(os.path.normpath(".."), opath.sep))
    proto, path = urllib.splittype(url)
    host, path = urllib.splithost(path)
    path = os.path.normpath(path)
    path_elements = string.split(path, opath.sep)
    if debug:
        print >>sys.stderr, "path_elements:", path_elements
        print >>sys.stderr, "host:", host
    if num_dotdots:
        path_elements = path_elements[:0-num_dotdots]
    return "%s://%s%s" % (proto, host,
                           string.join(path_elements, opath.sep))

def identity(x):
    return x

def all_substrings(s, first=0, last=None, string_pp=identity):
    return [ s[first:i+1] for i in xrange(first, last or len(s)) ]

def any_substring(a, s, first=0, last=None, string_pp=string.lower):
    if string_pp == None:
        string_pp = identity
    return string_pp(a) in all_substrings(string_pp(s), first, last)

        
