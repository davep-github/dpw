#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, errno
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

def process_file(file_name):
    escaped_newline = "\\\n"
    fop = open(file_name)
    concat_p = False
    total_line = ''
    lines = []
    for line in fop:
        dp_io.cdebug(2, "raw line>%s<\n", line)

        enewline_p = line[-2:] == escaped_newline
        if enewline_p:
            line = line[:-2]
            
        if concat_p:
            dp_io.cdebug(1, "1,concat_p is True, line>%s<\n", line)
            dp_io.cdebug(1, "1.1,concat_p is True, total_line>%s<\n", total_line)
            total_line = total_line + line
            dp_io.cdebug(1, "2,concat_p is True, total_line>%s<\n", total_line)
        else:
            dp_io.cdebug(1, "3,concat_p is False, line>%s<\n", line)
            total_line = line
            dp_io.cdebug(1, "4,concat_p is False, total_line>%s<\n", total_line)
        if enewline_p:
            dp_io.cdebug(1, "5,escaped_newline, line>%s<\n", line)
            #total_line = total_line + line[:-2]
            dp_io.cdebug(1, "6,escaped_newline, total_line>%s<\n", total_line)
            concat_p = True
            continue
        else:
            concat_p = False
        dp_io.cdebug(1, "7,final, total_line>%s<\n", total_line)
#        if (len(total_line) > 0) and total_line[-1] == "\n":
#            total_line = total_line[:-1]
        lines.append(total_line)
        total_line = ""
    fop.close()
    return lines


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
    oparser.add_argument("file_names", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    file_names = app_args.file_names

    for file_name in file_names:
        lines = process_file(file_name)
        for l in lines:
            dp_io.cdebug(4, "line>%s<\n", l)
            dp_io.undebug("%s", l)

if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        sys.exit(main(sys.argv))
    except IOError, e:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print >>sys.stderr, ":Broken PIPE:"
            sys.exit(BROKEN_PIPE_RC)
        print >>sys.stderr, "IOError>%s<" % (e,)
        sys.exit(IOERROR_RC)

