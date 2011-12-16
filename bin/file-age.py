#!/usr/bin/env python

import os, env, time, getopt

factors = {}

if __name__ == "XX__main__":

options, args = getopt.getopt(sys.argv[1:], 'hmsdu')
for (o, v) in options:
    if o == '-d':                       # Floating point # of days
        output_unit = factors[o[1]]
        continue
    
    
