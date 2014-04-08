#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, types
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
    line_num = 1
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
        bin_list.append((line, line_num))
        bins[bin_num] = bin_list
        # print >>sys.stderr, "len(bin_list):", len(bin_list)
        line_num += 1
        

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
    oparser.add_argument("--show-empty",
                         dest="show_empty_p",
                         default=False,
                         action="store_true",
                         help="Print empty bins.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    oparser.add_argument("input_files", nargs="*")

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
    if len(app_args.input_files) == 0:
        files = [sys.stdin]
    else:
        files = app_args.input_files
    #print >>sys.stderr, "input_files:", app_args.input_files
    for file in files:
        if type(file) == types.StringType:
            close_p = True
            file = open(file)
        else:
            close_p = False
        max_bin, bins = process_file(file, bin_size)
        if close_p:
            file.close()
        for bin_num in range(max_bin + 1):
            bin_list = bins.get(bin_num, [])
            if not app_args.show_empty_p and not bin_list:
                continue
            n = len(bin_list)
            if not app_args.show_empty_p and n == 0:
                continue
            bin_num = bin_num * bin_size
            b0 = bin_num
            bn_minus_one = b0 + bin_size - 1
            print "%05d[%d-%d]:\t%d" % (bin_num, b0, bn_minus_one, n)
            if verbose_p:
                for line, line_num in bin_list:
                    print "   {}: {}: {}".format(line_num, len(line), line)


if __name__ == "__main__":
    main(sys.argv)

