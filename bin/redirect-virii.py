#!/usr/bin/env python

import os, sys, re, types

def rewriter(trigger, header, replacement, instream=sys.stdin,
             ostream=sys.stdout):
    headers = []
    if type(trigger) == types.StringType:
        trigger = re.compile(trigger)

    while True:
        line = instream.readline();
        if not line:
            break                       # EOF
        ostream.write(line)
        if line == '\n':                # end o' headers
            break
        m = trigger.search(line)
        if m:
            oline = 'X-Was-' + line # Save original line prefixed with X-Was-
            line.replace(m.group(), replacement)
            ostream.write(oline)
    if line:
        while True:
            line = instream.readline()
            if not line:
                break
            ostream.write(line)
            
    return 0

if __name__ == "__main__":
    rewriter(*sys.argv[1:])
    sys.exit(0)
