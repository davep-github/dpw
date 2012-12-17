#!/usr/bin/env python
import os, sys, re, string, getopt

def sum_stream(istream, field_num=0, separator=None, num_to_skip=0):
    multipliers = {'M': 1024*1024,
                   'm': 1024*1024,
                   'K': 1024,
                   'k': 1024}
    total = 0
    cre = re.compile("(\d+)([MmKk]?)")
    #print >>sys.stderr, "num_to_skip:", num_to_skip
    line = istream.readline()
    while num_to_skip:
        if not line:
            break
        num_to_skip -= 1
        line = line [:-1]
        #print >>sys.stderr, "skip line>%s<" % line
        line = istream.readline()

    if not line:
        return 0

    while True:
        if not line:
            return total

        line = line [:-1]
        #print >>sys.stderr, "sum line>%s<" % (line,)

        field = string.split(line, separator)[field_num]
        m = cre.search(field)
        if m:
            num, mult = m.group(0), m.group(1)
            #print >>sys.stderr, "groups:", m.groups()
            #print >>sys.stderr, "m.g1:", m.group(0), "m.g2:", m.group(1)
            if mult:
                mult = multipliers.get(mult, 1)
            else:
                mult = 1
            total += eval(num) * mult
        line = istream.readline()

    return total

if __name__ == "__main__":
    field_num = 0
    separator = None
    num_to_skip = 0
    options, args = getopt.getopt(sys.argv[1:], 'f:s:n:')
    #print >>sys.stderr, "options:", options, "args:", args
    for o, v in options:
        if o == '-f':
            field_num = eval(v)
            continue
        if o == '-s':
            separator = v
            continue
        if o == '-n':
            num_to_skip = eval(v)
            continue
        print >>sys.stderr, "Unknown option:", o
        sys.exit(1)

    print "total:", sum_stream(sys.stdin, field_num, separator, num_to_skip)
