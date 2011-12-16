#!/usr/bin/env python
import os, sys, re, string, getopt

def sum_stream(istream, field_num=0, separator=None, num_to_skip=0):
    multipliers = {'M': 1024*1024,
                   'm': 1024*1024,
                   'K': 1024,
                   'k': 1024}
                   
    total = 0
    cre = re.compile("(\d+)([MmKk]?)")
    print "num_to_skip:", num_to_skip
    while num_to_skip:
        line = istream.readline()
        if not line:
            break
        num_to_skip -= 1
        line = line [:-1]
        print "skip line>%s<" % line

    if not line:
        return 0

    while True:
        line = istream.readline()
        if not line:
            return total

        line = line [:-1]
        print "sum line>%s<"

        field = string.split(line, separator)[field_num]
        m = cre.search(field)
        if m:
            num, mult = m.group(0), m.group(1)
            print "groups:", m.groups()
            print "m.g1:", m.group(0), "m.g2:", m.group(1)
            if mult:
                mult = multipliers.get(mult, 1)
            else:
                mult = 1
            total += eval(num) * mult
            
if __name__ == "__main__":
    field_num = 0
    separator = None
    num_to_skip = 0
    options, args = getopt.getopt(sys.argv[1:], 'f:s:n:')
    print "options:", options, "args:", args
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
    

  
