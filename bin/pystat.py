#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, errno
import argparse
import dp_io, dp_utils
import statistics, decimal, numpy

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

def compute_histogram(a, bins=10):
    ret = numpy.histogram(a, bins=bins)
    return ret[0]

def display_histogram(hist):
    for n in hist:
        s = n * '*'
        print s

##            (statistics.mean, "pys_mean"),
##            (statistics.stdev, "pys_stdev"),
##            (statistics.median, "pys_median"),

def pys_histogram(samples, bins=10, max=0, delta=0, min=0, *args):
    h = compute_histogram(samples, bins=bins)
    display_histogram(h)

def pys_max(samples, *args, **keys):
    dp_io.cdebug(1, "args>%s<\n", args)
    dp_io.cdebug(1, "keys>%s<\n", keys)
    return max(samples)

def pys_min(samples, *args, **keys):
    return min(samples)

def pys_mean(samples, *args, **keys):
    return statistics.mean(samples)

def pys_stdev(samples, *args, **keys):
    return statistics.stdev(samples)

def pys_median(samples, *args, **keys):
    return statistics.median(samples)

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
    oparser.add_argument("--and-histogram", "--ah",
                         dest="and_histogram_p",
                         default=False,
                         action="store_true",
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

    ops = ((pys_max, "max"),
           (pys_mean, "mean"),
           (pys_stdev, "stdev"),
           (pys_median, "median"),
           (pys_min, "min"),
           )

    if app_args.and_histogram_p:
        ops = ops + ((pys_histogram, "histogram"),)

    dp_io.cdebug(3, "ops: %s\n", ops)

    instrm = sys.stdin

    samples = []
    for s in instrm:
        samples.append(eval(s))
        dp_io.cdebug(1, "%d: s>%s<\n", len(samples)-1, s)

    dp_io.cdebug(1, "EOF\n")
    dp_io.printf("num_samples: %d\n", len(samples))

    if len(samples) == 0:
        print >>sys.stderr, "No samples, exiting."
        return 1

    maxv = pys_max(samples)
    minv = pys_min(samples)
    delta_max_min = maxv - minv
    args = []
    keys = {"max": maxv,
            "min": minv,
            "bins": 10,
            "delta": delta_max_min}
    for op, name in ops:
        dp_io.cdebug(1, "calling op>%s<, name>%s<, len(samples): %s\n",
                     op, name, len(samples))
        x = op(samples, *args, **keys)
        dp_io.cdebug(1, "performed op>%s<, result: %s\n", op, x)
        if name:
            fmt = "%s: %s\n"
        else:
            fmt = "%s%s\n"
        if x is not None:
            if app_args.engineering_notation_p:
                dp_io.cdebug(4, "x: %s\n", x)
                x = dp_utils.eng_notation_str(x)
            dp_io.printf(fmt, name, x)
    dp_io.printf("delta(max, min): %s\n",
                 dp_utils.eng_notation_str(delta_max_min))

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

