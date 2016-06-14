#!/usr/bin/env python

import sys, os

# Aiming for speed.

def main(nargv):
    ## argv looks like:
    ## [opts...] "path:like:single:args" separate args to add 
    isep = ":"
    osep = isep
    prepend_p = False
    argi = 1
    nargs = len(nargv)
    while argi < nargs:
        a = nargv[argi]
        #print >>sys.stderr, "examining>%s<, type(a): %s" % (a, type(a))
        if a[0] != '-':
            break
        argi += 1
        if a == '-p':
            prepend_p = True
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
        else:
            print >>sys.stderr, "Bad arg>%s<" % (a)
    #print >>sys.stderr, "nargv[%d:]>%s<" % (argi, nargv[argi:])

    if prepend_p:
        car_elements = nargv[argi + 1:] # separate args
        cdr_elements = nargv[argi].split(isep)  # path:like:arg
    else:
        car_elements = nargv[argi].split(isep)
        cdr_elements = nargv[argi + 1:]

    for i in range(car_elements.count('')):
        car_elements.remove('')

    for i in range(cdr_elements.count('')):
        cdr_elements.remove('')

    # remove duplicates of elements in car from cdr
    for d in car_elements:
        if d in cdr_elements:
            cdr_elements.remove(d)

    print osep.join(car_elements + cdr_elements)
