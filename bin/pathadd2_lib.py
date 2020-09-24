#!/usr/bin/env python2

import sys, os

# Aiming for speed.

def main(nargv):
    # argv looks like:
    # [opts...] "path-like:single:args" separate args to add
    # --> "path-like:single:separate:args:to:add"
    isep = ":"
    osep = isep
    prepend_p = False
    delete_p = False

    # Extraordinarily crude parsing, for speed of course.
    argi = 1
    nargs = len(nargv)

    if False:
        print >>sys.stderr, "pathadd2_lib.main(): nargv>%s<" % (
            "<\n>".join(nargv))

    while argi < nargs:
        a = nargv[argi]
        # print >>sys.stderr, "examining nargv[%d]>%s<, type(a): %s" % (argi,
        #                                                               a,
        #                                                               type(a))
        if (len(a) == 0) or (a[0] != '-'):
            break
        argi += 1               # Consume option char.
        if a == '-p':
            prepend_p = True
        elif a == '-d':
            delete_p = True
        elif a == '-s':
            isep = nargv[argi]
            osep = isep
            argi += 1
            #print >>sys.stderr, "isep>%s<" % (isep,)
            #print >>sys.stderr, "osep>%s<" % (osep,)
        elif a == '-i':
            isep = nargv[argi]
            argi += 1
            #print >>sys.stderr, "isep>%s<" % (isep,)
        elif a == '-o':
            osep = nargv[argi]
            argi += 1
            #print >>sys.stderr, "osep>%s<" % (osep,)
        elif a == '-S':
            isep = ' '
            osep = ' '
        elif a == '-':
            # a sign (NPI) that something is probably wrong; ignore it and
            continue
            # print >>sys.stderr, "pathadd2(): Not so good arg>%s<, ignoring" % (a,)
        else:
            print >>sys.stderr, "pathadd2(): Bad arg>%s<" % (a)
    # print >>sys.stderr, "len(nargv): %d, nargv[%d:]>%s<" % (len(nargv),
    #                                                         argi, nargv[argi:])

    # print "len(nargv): %d, argi: %d" % (len(nargv), argi)
    if argi >= len(nargv):
        path_elements = []
        new_elements = []
    else:
        path_elements = nargv[argi].split(isep)
        new_elements = nargv[argi + 1:]

    for i in range(new_elements.count('')):
        new_elements.remove('')

    for i in range(path_elements.count('')):
        path_elements.remove('')

    ## print "1:new_elements:", osep.join(new_elements)
    ## print "1:path_elements:", osep.join(path_elements)

    # remove duplicates of elements in car from cdr
    for d in new_elements:
        while d in path_elements:
            #print d, "in", path_elements
            path_elements.remove(d)
            #print d, "in", path_elements
    #print "delete_p:", delete_p
    #print "2:new_elements:", osep.join(new_elements)
    #print "2:path_elements:", osep.join(path_elements)

    if delete_p:
        elements = path_elements
    elif prepend_p:
        elements = new_elements + path_elements
    else:
        elements = path_elements + new_elements

    # Output new string of elements.
    print osep.join(elements)
