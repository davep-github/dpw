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

def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. "
                         "dp_io.cdebug(<n>, fmt [, ...])")
    oparser.add_argument("--verbose-level",
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
    oparser.add_argument("-p", "--prepend",
                         dest="prepend_p",
                         default=False,
                         action="store_true",
                         help="Prepend path items.")
    oparser.add_argument("-s", "--separator",
                         dest="separator",
                         default=":",
                         type=str,
                         help="What to separate path elements with.")
    oparser.add_argument("-S", "--separate-with-spaces",
                         dest="separate_with_spaces_p",
                         default=False,
                         action="store_true",
                         help="Separate with spaces.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("non_option_args", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    nargv = app_args.non_option_args
    sep = app_args.separator
    if app_args.prepend_p:
        car_elements = nargv[1:]
        cdr_elements = nargv[0].split(sep)
    else:
        car_elements = nargv[0].split(sep)
        cdr_elements = nargv[1:]

    for i in range(car_elements.count('')):
        car_elements.remove('')

    for i in range(cdr_elements.count('')):
        cdr_elements.remove('')

    # remove duplicates of elements in car from cdr
    for d in car_elements:
        if d in cdr_elements:
            cdr_elements.remove(d)

    print sep.join(car_elements + cdr_elements)

if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        main(sys.argv)
    except IOError:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print >>sys.stderr, ":Broken PIPE:"
            sys.exit(BROKEN_PIPE_RC)
        print >>sys.stderr, "IOError>%s<" % (e,)
        sys.exit(IOERROR_RC)

