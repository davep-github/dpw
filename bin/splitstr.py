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

#
# Perform arbitrary actions to process an argument within the argparse framework.
# e.g. class App_arg_action(argparse.Action):
# e.g.     def __call__(self, parser, namespace, values, option_string=None):
# e.g.         regexps = getattr(namespace, self.dest)
# e.g.         regexps.append(values)
# e.g.         setattr(namespace, self.dest, regexps)
# e.g.         setattr(namespace, "highlight_grep_matches_p", True) 

def main(argv):
    ostream = sys.stdout
    oparser = argparse.ArgumentParser()
    oparser.add_argument("-d", "--debug", "--dl",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. "
                         "dp_io.cdebug(<n>, fmt [, ...])")
    oparser.add_argument("-v", "--verbose-level", "--vl",
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
    oparser.add_argument("-p", "--path",
                         dest="split_path_p",
                         default=False,
                         action="store_true",
                         help="String being split is a PATH:type:string."
                         "overrides --sep, et. al.")
    oparser.add_argument("-s", "--sep", "--split-on", "--split-char",
                         type=str,
                         dest="sep",
                         default=":",
                         help="String on which to split the input strings(s?).")
    oparser.add_argument("-r", "--rep", "--repl", "--repl-str", "--repl-by-str",
                         type=str,
                         dest="repl_by_str",
                         default="\n",
                         help="Unused.String to separate the split strings(s?).")
    oparser.add_argument("--maxsplit", "--ms",
                         dest="maxsplit",
                         type=int,
                         default=-1,
                         help="Max number of splits to do.")
    oparser.add_argument("--end",
                         dest="end",
                         type=str,
                         default="\n",
                         help="Last char to output.")


# e.g.     oparser.add_argument("--app-action", "--aa",
# e.g.                          dest="app_action_stuff", default=[],
# e.g.                          action=App_arg_action,
# e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args, first arg is name that goes into app_args.
    oparser.add_argument("strings", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print("I am being quiet.")
    if app_args.debug_level >= 0:
        #dp_io.debug_on(debug)
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable_debugging_p=True)
    # 1/10 of 1 uerg saved using -p rather than --sep=':'
    # Spend more energy typing the statement than I'll save in 37 years.
    if app_args.split_path_p:
        app_args.sep = ':'

    dp_io.cdebug(1, "Enter main(%s)\n", argv)

    ## D'OI, why not use repl?
    while True:
        s = sys.stdin.readline()
        dp_io.cdebug(1, "read s>%s<\n",s)
        s = s[:-1]
        if not s:
            break
        #print("s>{}<, split>{}<".format(s, app_args.sep))
        dp_io.cdebug(1, "s>%s<, split>%s<\n", s, app_args.sep)
        subs = s.split(app_args.sep)
        dp_io.cdebug(1, "subs>%s<\n", subs)
        subs_count = subs
        for s in subs:
            subs_count = subs_count[:-1]
            if subs_count:
                repl = app_args.repl_by_str
            else:
                repl = ""
            dp_io.printf("%s%s", s, repl)
            #dp_io.printf(">%s<]%s[\n", s, app_args.repl_by_str)
        # I hate magic, but...
        if app_args.end != app_args.repl_by_str:
            dp_io.printf("%s", app_args.end)
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
