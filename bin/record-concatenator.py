#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, errno, re
import argparse

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

def join_records(file_name, continuation_pattern="<NL>BLAH: ", cont_sep=" "):
    """Return a list of joined lines w/o newlines.
This makes the results usable in a variety of applications."""

    if type(file_name) == type(""):
        fop = open(file_name)
        opened_p = True
    else:
        fop = file_name
        opened_p = False
    coninuation_pattern_cre = re.compile(continuation_pattern)
    total_line = ''
    lines = []
    for line in fop:
        if line[-1:] == "\n":
            line = line[0:-1]
        continuation_line_p = coninuation_pattern_cre.search(line)
        if continuation_line_p:
            line = coninuation_pattern_cre.sub("", line)
            total_line = total_line + cont_sep + line
        elif total_line:
            lines.append(total_line)
            total_line = line
        else:
            total_line = line
    if total_line:
        lines.append(line)
    if opened_p:
        fop.close()
    return lines

def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("-q", "--quiet",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
    oparser.add_argument("-c", "--cont-pattern", "--continuator",
                         dest="continuation_pattern",
                         default="<NL>BLAH: ", type=str,
                         help="Regexp that says the current line is a continuation line.")
    oparser.add_argument("-s", "--cont-sep", "--joiner",
                         dest="cont_sep",
                         default=" ", type=str,
                         help="String to separate joined lines.")
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

    file_names = app_args.file_names

    if not file_names:
        file_names = (sys.stdin,)

    for file_name in file_names:
        lines = join_records(file_name,
                             continuation_pattern=app_args.continuation_pattern,
                             cont_sep=app_args.cont_sep)
#        lines = join_records(file_name)
        for l in lines:
            print l

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
