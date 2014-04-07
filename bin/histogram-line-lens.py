#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse
import dp_io

DEFAULT_BIN_SIZE = 100

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.         setattr(namespace, "highlight_grep_matches_p", True)

def process_file(fobj, bin_size = DEFAULT_BIN_SIZE):
    max_bin = -1
    bins = {}
    for line in fobj:
        if not line:
            break
        line = line[0:-1]
        line_len = len(line)
        bin_num = line_len / bin_size;
        # print >>sys.stderr, "line_len:", line_len, ", bin_num:", bin_num
        if bin_num > max_bin:
            max_bin = bin_num
        # print >>sys.stderr, "max_bin:", max_bin
        bin_list = bins.get(bin_num, [])
        bin_list.append(line)
        bins[bin_num] = bin_list
        # print >>sys.stderr, "len(bin_list):", len(bin_list)
        

    return (max_bin, bins)
    
def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level")
    oparser.add_argument("--verbose-level",
                         dest="verbose_level",
                         type=int,
                         default=-1,
                         help="Set verbose/trace level")
    oparser.add_argument("--bin-size",
                         type=int,
                         default=DEFAULT_BIN_SIZE,
                         help="How wide are the bins?")
    oparser.add_argument("-q", "--quiet",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
    oparser.add_argument("--verbose", 
                         dest="verbose_p",
                         default=False,
                         action="store_true",
                         help="Print lines and their size.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.verbose_level, enable_debugging_p=True)

    bin_size = app_args.bin_size
    verbose_p = app_args.verbose_p
    max_bin, bins = process_file(sys.stdin, bin_size)
    for bin_num in range(max_bin + 1):
        bin_list = bins.get(bin_num, [])
#        if not bin_list:
#            continue
        n = len(bin_list)
#        if n == 0:
#            continue

        bin_num = bin_num * bin_size
        print "%05d: %d" % (bin_num, n)
        if verbose_p:
            for line in bin_list:
                print "   {}: {}".format(len(line), line)


if __name__ == "__main__":
    main(sys.argv)

