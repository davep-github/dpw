#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse
import dp_io, dp_utils, dp_sequences

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

def handle_fobj(fobj, sep=None):
    line_list = dp_utils.list_from_fobj_lines(fobj, sep=sep)
    dp_io.ctracef(3, "line_list>%s<\n", line_list)
    dp_io.printf("list:\n%s\n",
                 dp_sequences.list_to_indented_string(line_list, indent_str=""))
    dp_io.ctracef(3, "handle_fobj(), returning\n")

def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
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
    oparser.add_argument("-s", "--sep", "--separator",
                         dest="separator",
                         type=str,
                         default=None,
                         help="Set separator on which to split lines.")

##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("non_option_args", nargs="*")

    app_args = oparser.parse_args()
    files = app_args.non_option_args
    if app_args.quiet_p:
        print("I am being quiet.")
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    if files:
        dp_io.ctracef(3, "main(), files>%s<\n", files);
        for f in files:
            dp_io.ctracef(3, "main(), processing>%s<\n", f);
            try:
                fobj = open(f)
            except IOError:
                line_list = []
                continue                #??? or exit?
            handle_fobj(fobj, app_args.separator)
            fobj.close()
            dp_io.ctracef(3, "main(), done with>%s<\n", f);
    else:
        handle_fobj(sys.stdin, app_args.separator)
    dp_io.ctracef(3, "main(), returning\n");

if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        main(sys.argv)
    except IOError:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print(":Broken PIPE:", file=sys.stderr)
            sys.exit(BROKEN_PIPE_RC)
        print("IOError>%s<" % (e,), file=sys.stderr)
        sys.exit(IOERROR_RC)
