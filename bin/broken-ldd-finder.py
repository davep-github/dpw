#!/usr/bin/env python

import sys, os, re

## e.g.
## /usr/bin/akonadi_nepomuk_calendar_feeder:
##         linux-gate.so.1 =>  (0xb76f0000)
##         libQtCore.so.4 => /usr/lib/qt4/libQtCore.so.4 (0xb6b9d000)
##         libnepomuk.so.4 => not found
## -OR-
## /usr/bin/2to3:
##        not a dynamic executable

classification_table = {
    lib_cre: process_lib_line,
    bin_cre: process_bin_line,
    not_found_cre: process_not_found_line,
    not_dynamic_cre: process_not_dynamic_line}

class State(object):
    def __init__(line_valid_p, next_state, match=None):
        self.d_line_valid_p = line_valid_p
        self.d_next_state = next_state
        self.d_match = match

    def match_line(self, cre, line):
        self.d_match = cre.search(line)
        return self.d_match
    
    def match(self):
        return self.d_match

    def line_valid_p(self):
        return d_line_valid_p

    def next_state(self):
        return d_next_state
    

Libs = {}                               # lib_path_name: count
Short_libs = {}                         # lib_short_name: count
Not_found_libs = {}                       # lib_short_name: count
Bins = {}
lib_cre = re.compile("(\s+)(?P<short_name>\S+)(\s+=>\s+)(?P<val>\S*)(?P<rest>.*$)")
not_found_cre = re.compile("not found")


not_dynamic_cre = re.compile("?P<short_name>\s+not a dynamic executable\s*$")
bin_cre = re.compile("(?P<name>^/.*):$")
# New binary name line begins a sequence:
# 1 not_dynamic_cre lines
# n lib_cre lines
# Both are handled in process_lib_line since they are in that section.
def process_bin_line(line, m):
    Current_bin = m.group("name")
    Bins[Current_bin] = line            # Anything non-None. The key is the name

def process_lib_line(line, m):
    #         libQtCore.so.4 => /usr/lib/qt4/libQtCore.so.4 (0xb6b9d000)
    n = Libs.get(short_name, 0)
    n += 1
    Libs[m.group("name")] = n
    return State(True, process_lib_line)

def process_not_dynamic_line(line, m):
    # Toss it.

def classify_line(line, m):
    for cre, next_fun in vector_table.items():
        m = cre.search(line)
        if m:
            return State(True, next_fun, m)
        wtf(line)
        ## next state is invalid so we call our self on the next line.
        return State(False, classify_line)
        
def state_driver(istream):
    for line in istream:
        state = classify_line(line)
        state.next_state(line, state.match())
        
def main(argv):
    import getopt
    opt_string = ""
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-<option-letter>':
            # Handle opt
            continue

if __name__ == "__main__":
    main(sys.argv)


