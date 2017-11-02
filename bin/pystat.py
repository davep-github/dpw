#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, errno
import argparse
import dp_io, dp_utils
import statistics
import decimal

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

def num_samples(samples):
    return len(samples)

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
    oparser.add_argument("-e", "--eng",
                         dest="engineering_notation_p",
                         default=True,
                         action="store_true",
                         help="Display output in engineering notation.")
    oparser.add_argument("-no-e", "--no-eng",
                         dest="engineering_notation_p",
                         default=True,
                         action="store_false",
                         help="Don't display output in engineering notation.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("non_option_args_like_file_names, etc.", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    ops = ((max, "max"),
           (statistics.mean, "mean"),
           (statistics.stdev, "stdev"),
           (statistics.median, "median"),
           (min, "min"),
           )
    instrm = sys.stdin

    samples = []
    while True:
        s = instrm.readline()
        s = s[:-1]
        if not s:
            dp_io.cdebug(1, "empty line EOF.\n")
            break
        samples.append(eval(s))
        dp_io.cdebug(1, "%d: s>%s<\n", len(samples)-1, s)

    dp_io.cdebug(1, "EOF\n")
    dp_io.printf("num_samples: %d\n", len(samples))

    if len(samples) == 0:
        print >>sys.stderr, "No samples, exiting."
        return 1
        
    for op, name in ops:
        dp_io.cdebug(1, "calling op>%s<, len(samples): %s\n", op, len(samples))
        x = op(samples)
        dp_io.cdebug(1, "performed op>%s<, result: %s\n", op, x)
        if name:
            fmt = "%s: %s\n"
        else:
            fmt = "%s%s\n"
        if app_args.engineering_notation_p:
            x = dp_utils.eng_notation_str(x)
        dp_io.printf(fmt, name, x)
    dp_io.printf("delta(max, min): %s\n",
                 dp_utils.eng_notation_str(max(samples) - min(samples)))

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

