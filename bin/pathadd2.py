#!/usr/bin/env python

import sys, os

# Aiming for speed.

if __name__ == "__main__":

    sep = ":"
    prepend_p = False
    nargs = 1
    for a in sys.argv[1:]:
        if a[0] != '-':
            break
        nargs += 1
        if a == '-p':
            prepend_p = True
        elif a[0:1] == '-s':
            sep = a[2:]
            sys.argv.remove(s)
        elif a == '-S':
            sep = ' '
        else:
            print >>sys.stderr, "Bad arg>%s<" % (a)

    nargv = sys.argv

    if prepend_p:
        car_elements = nargv[nargs + 1:]
        cdr_elements = nargv[nargs].split(sep)
    else:
        car_elements = nargv[nargs].split(sep)
        cdr_elements = nargv[nargs + 1:]

    for i in range(car_elements.count('')):
        car_elements.remove('')

    for i in range(cdr_elements.count('')):
        cdr_elements.remove('')

    # remove duplicates of elements in car from cdr
    for d in car_elements:
        if d in cdr_elements:
            cdr_elements.remove(d)

    print sep.join(car_elements + cdr_elements)
