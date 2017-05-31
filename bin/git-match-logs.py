#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse
import dp_io

debug_file = sys.stderr
verbose_file = sys.stderr
warning_file = sys.stderr

BROKEN_PIPE_RC = 1
IOERROR_RC = 1

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.         setattr(namespace, "highlight_grep_matches_p", True)

def zip_lines(l1, l2):
    i = 0
    n = max(len(l1), len(l2))
    col_wid = 5
    while i < n:
        if i >= len(l1):
            lline = ""
        else:
            lline = l1[i]
        lline = lline + col_wid * 2 * " "
        lline = lline[0:col_wid]

        if i >= len(l2):
            rline = ""
        else:
            rline = l2[i]
        rline = rline + col_wid * 2 * " "
        rline = rline[0:col_wid]
        dp_io.printf("%s | %s |\n", lline, rline)
        i = i + 1
    
def read_lines(file_name):
    lines = []
    input_lines = open(file_name).readlines()
    dp_io.ldebug(2, "reading>%s<, lines: %s\n",
                 file_name, len(input_lines))
    line_num = 0
    for l in input_lines:
        #dp_io.cdebug(5, "%3d>%s<\n", line_num, l)
        if l[-1] in "\n\r":
            l = l[:-1]
        lines.append(l)
        line_num = line_num + 1

    return lines

def dump_lines(lines, title=None):
    if title:
        dp_io.printf("dumping lines: %s:\n", title or "Untitled")

    line_num = 0
    for l in lines:
        dp_io.printf("%3d>%s<\n", line_num, l)
        line_num = line_num + 1
    if line_num > 0:
        dp_io.printf("end of %s=================\n", title or "Untitled")

def main(argv):
    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug", "--dl",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. "
                         "dp_io.cdebug(<n>, fmt [, ...])")
    oparser.add_argument("--verbose-level", "--vl",
                         dest="verbose_level",
                         type=int,
                         default=-1,
                         help="Set verbose/trace level. Use with, e.g. "
                         "dp_io.ctracef(<n>, fmt [, ...])")
    oparser.add_argument("-q", "--quiet",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("input_files", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    input_files = app_args.input_files
    left_lines = read_lines(input_files[0])
    dp_io.cdebug(5, "len(left_lines): %d\n", len(left_lines))

    right_lines = read_lines(input_files[1])
    dp_io.cdebug(5, "len(right): %d\n", len(right_lines))
#    dump_lines(left_lines, "left")
#    dump_lines(right_lines, "right")

    # find first line in 1 that is in 2
    flinr = 0
    frinl = None
    for l in left_lines:
        if l[-1] in "\n\r":
            l = l[:-1]
        dp_io.ldebug(5, "l[%d]>%s<\n", flinr, l)
        try:
            frinl = right_lines.index(l)
            dp_io.ldebug(2, "Found line.\n")
            break
        except ValueError:
            flinr = flinr + 1
            pass

    luniq = []
    runiq = []
    dp_io.ldebug(2, "flinr: %s, frinl: %s\n", flinr, frinl)
    if flinr is not None:
        runiq = right_lines[0:frinl]
        right_lines = right_lines[frinl:]
        dump_lines(runiq, "runiq")
        dp_io.printf("2[flinr]>%s<\n", left_lines[flinr])
    if frinl is not None:
        luniq = left_lines[0:flinr]
        left_lines = left_lines[flinr:]
        dump_lines(luniq, "luniq")
        dp_io.printf("1[frinl]>%s<\n", right_lines[frinl])

    rfirst = [""] * len(luniq) + runiq
    lfirst = luniq +  [""] * len(runiq)
    left_lines = lfirst + ["=========="] + left_lines
    right_lines = rfirst + ["=========="] + right_lines
    dump_lines(left_lines, "left")
    dump_lines(right_lines, "right")

    zip_lines(left_lines, right_lines)
    sys.exit(99)
    
            

if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        sys.exit(main(sys.argv))
    except IOError:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print >>sys.stderr, ":Broken PIPE:"
            sys.exit(BROKEN_PIPE_RC)
        print >>sys.stderr, "IOError>%s<" % (e,)
        sys.exit(IOERROR_RC)

