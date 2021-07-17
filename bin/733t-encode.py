#!/usr/bin/env python

#
# davep's standard Python file template.
# /home/davep/bin/templates/python-template.py
#

import os, sys, errno
import argparse
import dp_io

debug_file = sys.stderr
verbose_file = sys.stderr
warning_file = sys.stderr

BROKEN_PIPE_RC = 1
IOERROR_RC = 1
motivation = """Take an easily remembered and legible and randomly translate chars to
randomized leet equlivalents.
E.g.  Hello -> h3L10.
so we'll have a hash like, character to list of various replacements.
Also, random case flipping.
E.g. "l" --> [ 'flip-case", '1', 'i', '|' ]
@todo Have a way to define, detect and bypass translation to sketchy chars. Some
places don't like, say |, \ or often just Unix specials.  And " ".
There's probably a ton of tools for thing, but nothing's more configurable
than elisp.

translator:
{ char: [selector_func, r0, r1, ...] }

Also, do some doggo speak, then optionally leet it.
E.g.  Hello -> henlo.  Possibly to heNl0
"""

class Translation_table(object):
    def __init__(self, tranlation_table):
        self.tranlation_table
    

class L33tener(object):
    def __init__(translation_table)


#
# Perform arbitrary actions to process an argument within the argparse framework.
# e.g. class App_arg_action(argparse.Action):
# e.g.     def __call__(self, parser, namespace, values, option_string=None):
# e.g.         regexps = getattr(namespace, self.dest)
# e.g.         regexps.append(values)
# e.g.         setattr(namespace, self.dest, regexps)
# e.g.         setattr(namespace, "highlight_grep_matches_p", True)

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
# e.g.     oparser.add_argument("--app-action", "--aa",
# e.g.                          dest="app_action_stuff", default=[],
# e.g.                          action=App_arg_action,
# e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args, first arg is name that goes into app_args.
    oparser.add_argument("non_option_args_like_file_names, etc.", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print("I am being quiet.")
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable_debugging_p=True)


if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        sys.exit(main(sys.argv))
    except IOError as e:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print(":Broken PIPE:", file=sys.stderr)
            sys.exit(BROKEN_PIPE_RC)
        print("IOError>%s<" % (e,), file=sys.stderr)
        sys.exit(IOERROR_RC)