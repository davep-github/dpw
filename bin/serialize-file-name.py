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

def serialize_one(file_name, num_tries):
    dp_io.cdebug(1, "file_name>{}<\n", file_name)
    non_ext, ext = os.path.splitext(file_name)
    file_format = "{}{}{}".format(non_ext, "{}", ext)
    for attempt in [""] + [ ".%d" % (x,) for x in range(num_tries) ]:
        try_name = file_format.format(attempt)
        dp_io.cdebug(1, "try_name>{}<, non_ext>{}<, ext>{}<\n",
                     try_name, non_ext, ext)
        try:
            fd = os.open(try_name, os.O_EXCL | os.O_CREAT)
        except OSError:                 # ? Make this more precise?
            continue
        os.close(fd)
        print try_name
        return 0

    return 1

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
    oparser.add_argument("-t", "--num", "--num-tries", "--tries",
                         dest="num_tries",
                         type=int,
                         default=100,
                         help="Number of tries to find unique serialized name.")

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
    num_tries = app_args.num_tries
    num_failures = 0
    for file_name in app_args.file_names:
        rc = serialize_one(file_name, num_tries)
        if rc != 0:
            num_failures += 1
            dp_io.eprintf("Error serializing {}, {} times\n", file_name, num_tries)
    if num_failures != 0:
        dp_io.eprintf("Some files could not be serialized.\n")

    if num_failures:
        return 1
    else:
        return 0

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

