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

NEWLINE_CONTINUATION_REGEXP = "\\\\$"

BROKEN_PIPE_RC = 1
IOERROR_RC = 1

def dump_cont_pat(continuation_regexp, *args, **keys):
    prefix = keys["prefix"]
    dp_io.printf("%scontinuation_regexp>%s<\n", prefix,
continuation_regexp)
    for c in continuation_regexp:
        dp_io.printf("%sc>%s<\n", prefix, c)

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.setattr(namespace, "highlight_grep_matches_p", True)

def process_file(file_name,
                 continuation_regexp=NEWLINE_CONTINUATION_REGEXP,
                 sep='',
                 nuke_regexp=None):

    dp_io.debug_exec(1, dump_cont_pat, continuation_regexp)
    if type(file_name) == type(""):
        fop = open(file_name)
        close_p = True
    else:
        fop = file_name
        close_p = False
    concat_p = False
    total_line = ''
    lines = []
    if type(continuation_regexp) == type(""):
        continuation_regexp = re.compile(continuation_regexp)

    for line in fop:
        dp_io.cdebug(3, "raw line>%s<\n", line)
        line = str.rstrip(line, '\n')
        dp_io.cdebug(3, "stripped>%s<\n", line)

        continued_line = continuation_regexp.search(line)
        if continued_line:
            line = continuation_regexp.sub("", line)
            dp_io.cdebug(3, "continued_line?line>%s<\n", line)

        if concat_p:
            dp_io.cdebug(2, "1,concat_p is True, line>%s<\n", line)
            dp_io.cdebug(1, "1.1,concat_p is True, total_line>%s<\n", total_line)
            if nuke_regexp:
                # use ^ to nuke a prefix.
                continuation_regexp.sub("", line)
            total_line = total_line + sep + line
            dp_io.cdebug(2, "2,concat_p is True, total_line>%s<\n", total_line)
        else:
            dp_io.cdebug(2, "3,concat_p is False, line>%s<\n", line)
            total_line = line
            dp_io.cdebug(2, "4,concat_p is False, total_line>%s<\n", total_line)
        if continued_line:
            dp_io.cdebug(2, "5,escaped_newline, line>%s<\n", line)
            dp_io.cdebug(2, "6,escaped_newline, total_line>%s<\n", total_line)
            concat_p = True
            continue
        else:
            concat_p = False
        dp_io.cdebug(2, "7,final, total_line>%s<\n", total_line)
        lines.append(total_line)
        total_line = ""
    if close_p:
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
    oparser.add_argument("-c", "--continuation-pat", "--cp",
                         dest="continuation_regexp",
                         type=str,
                         default=NEWLINE_CONTINUATION_REGEXP,
                         help="Continuation indicator")
    oparser.add_argument("-s", "--sep", "--separator",
                         dest="separator",
                         type=str,
                         default="",
                         help="Separate continuations with this.")
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
    if not file_names:
        file_names = (sys.stdin,)
    for file_name in file_names:
        lines = process_file(file_name,
                             continuation_regexp=app_args.continuation_regexp,
                             sep=app_args.separator)
        for l in lines:
            dp_io.cdebug(5, "line>%s<\n", l)
            # dp_io.undebug("%s", l)
            dp_io.printf("%s\n", l)

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
