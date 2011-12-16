#!/usr/bin/env python

import sys, os
import dp_io

def sort_by_len(strings):
    strings_by_len = {}
    for s in strings:
        s = s[:-1]
        l = len(s)
        strings_by_len[l] = strings_by_len.get(l,[]) + [s]
    return strings_by_len

def sort_and_print_strings(strings, printor=dp_io.printf):
    strings_by_len = sort_by_len(strings)
    lengths = strings_by_len.keys()
    lengths.sort()
    for length in lengths:
        lines = strings_by_len[length]
        for l in lines:
            printor("%s\n", l)

def read_files(files):
    strings = []
    for f in args:
        fob = open(f)
        strings = strings + fob.readlines()
        fob.close()
    return strings
    
def sort_and_print_files(files):
    sort_and_print_strings(read_files(files))

def sort_and_print_fobs(file_objects):
    strings = []
    for fob in file_objects:
        strings = strings + fob.readlines()
    sort_and_print_strings(strings)

def main(argv):
    import getopt
    opt_string = ""
    opts, args = getopt.getopt(argv[1:], opt_string)
    #for o, v in opts:
    #    if o == '-<option-letter>':
    #        # Handle opt
    #        continue
    if args:
        sort_and_print_files(args)
    else:
        sort_and_print_fobs([sys.stdin])
        

if __name__ == "__main__":
    main(sys.argv)


