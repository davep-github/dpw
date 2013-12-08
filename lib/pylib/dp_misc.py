#!/usr/bin/env python

#############################################################################
## @package
##
import sys, os, urllib, string, types
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

def normpath_plus(path, plus=opath.sep):
    return opath.normpath(path) + plus

def mkpath0(split_path):
    ppart = split_path[0]
    dpart = split_path[1]
    if os.exists(ppart) and opath.isdir(ppart):
        os.mkdir(ppart + opath.sep + dpart)
        return
    mkpath0(opath.split(dpart))

def mkpath(path_string_or_list):
    print >>sys.stderr, "path_string_or_list>{}<".format(path_string_or_list)
    if type(path_string_or_list) == types.StringType:
        npath = opath.normpath(path_string_or_list)
        print >>sys.stderr, "npath>{}<".format(npath)
        elements = npath.split(opath.sep)
    else:
        elements = path_string_or_list
    print >>sys.stderr, "elements>{}<".format(elements)
    p = elements[0]
    elements = elements[1:]
    for element in elements:
        print >>sys.stderr, "element>{}<".format(element)
        print >>sys.stderr, "p>{}<".format(p)
        if opath.exists(p) and opath.isdir(p):
            pass
        else:
            # If p is a file, we'll raise an appropriate error.
            os.mkdir(p)
        p = p + opath.sep + element

if __name__ == "__main__":
    mkpath(sys.argv[1])
