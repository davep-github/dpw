#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, errno, re
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
##e.g.setattr(namespace, "highlight_grep_matches_p", True) 

def process_file(file_name, regexp, num_to_skip):
    if type(file_name) == type(""):
        fop = open(file_name)
        close_p = True
    else:
        close_p = False
    if num_to_skip < 0:
        print_match_p = True
        num_to_skip = -num_to_skip
    else:
        print_match_p = False

    cat_p = False
    cre = re.compile(regexp)
    for line in fop:
        if cat_p:
            print line,
            continue
        if not cre.search(line):
            continue
        num_to_skip -= 1
        cat_p = (num_to_skip <= 0)
        if cat_p and print_match_p:
            print line,

    if close_p:
        fop.close()

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
    oparser.add_argument("-n", "--num-to-skip",
                         dest="num_to_skip",
                         type=int,
                         default=1,
                         help="Begin catenating files after seeing the regexp this many times.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args, first arg is name that goes into app_args.
    oparser.add_argument("file_names", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    file_names = app_args.file_names
    regexp = file_names[0];
    file_names = file_names[1:]

    if not file_names:
        file_names = (sys.stdin,)
    for file_name in file_names:
        process_file(file_name, regexp, app_args.num_to_skip)

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

