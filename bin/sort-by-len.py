#!/usr/bin/env python

import sys, os
import dp_io

# Can I have used a sort arg to sort?  Doing this allows me to sort an
# array based on the value of a property of the array members (e.g. string
# len) rather than the values of the members.
# It's already written and works, bone-headed as it may be.
def arrange_by_len(strings):
    strings_by_len = {}
    for s in strings:
        s = s[:-1]
        l = len(s)
        strings_by_len[l] = strings_by_len.get(l,[]) + [s]
    return strings_by_len

def sort_and_print_strings(strings, reverse_sort_p, printor=dp_io.printf):
    strings_by_len = arrange_by_len(strings)
    lengths = strings_by_len.keys()
    lengths.sort(reverse=reverse_sort_p)
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
    
def sort_and_print_files(files, reverse_sort_p):
    sort_and_print_strings(read_files(files, reverse_sort_p))

def sort_and_print_fobs(file_objects, reverse_sort_p):
    strings = []
    for fob in file_objects:
        strings = strings + fob.readlines()
    sort_and_print_strings(strings, reverse_sort_p)

def main(argv):
    import getopt
    opt_string = "hr"
    reverse_sort_p = False
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-h':
            print "Sort input lines by length."
            continue
        if o == '-r':
            reverse_sort_p = True
            continue
    if args:
        sort_and_print_files(args, reverse_sort_p)
    else:
        sort_and_print_fobs([sys.stdin], reverse_sort_p)
        

if __name__ == "__main__":
    main(sys.argv)


