#!/usr/bin/env python

import sys, os, string, re, getopt, types

def grep_for_regexp(f, regexp, last_line=None, reuse_line_p=False):
    while True:
        if (reuse_line_p and last_line[0]):
            l = last_line[0]
        else:
            l = f.readline()
            last_line[0] = l
        if not l:
            return None
        if l[-1] in "\r\n":
            l = l[:-1]
        m = regexp.search(l)
        if m:
            return (l, m)
    return None

def grep_file(file_name, regexps, name=None):
    if type(file_name) == types.FileType:
        f = file_name
        # Use name
        closeit = False
    else:
        f = open(file_name, 'r')
        name = name or file_name        # name overrides
        closeit = True
    last_line = [None]
    for regexp, flags in regexps:
        ml = grep_for_regexp(f, regexp, last_line, flags.get("reuse_line_p"))
        if ml and not flags.get("quiet_p", False):
            if name:
                sys.stdout.write("%s: " % name)
            print ml[0]
        else:
            continue
    if closeit:
        f.close()

def grep_files(file_names, regexps):
    if file_names == []:
        grep_file(sys.stdin, regexps, name=None)
    else:
        for f in file_names:
            grep_file(f, regexps)

if __name__ == "__main__":
    regexps = []
    re_options = ""
    quiet_p = False
    reuse_line_p = False
    options, args = getopt.getopt(sys.argv[1:], 'e:qf:i:x:R')
    for opt, val in options:
        # These flags must be set before the -e or -x options.
        # And so must also exist first on the command line.
        # They only apply to the next -e/-x option.
        if opt == '-q':
            quiet_p = True
            continue
        if opt == '-R':
            reuse_line_p = True
            continue
        if opt == '-i':
            re_options += "i"
            continue
        if opt == '-f':
            if val == '-':
                re_options = ""
            else:
                re_options = val
            continue
        if opt == '-F':
            re_options += val
            continue
        if opt == '-e' or opt == '-x':
            if re_options:
                o = "(?%s)" % re_options
            else:
                o = ""
            if opt == '-x':
                val = re.escape(val)
            regexps.append((re.compile(val+o),
                            {"quiet_p": quiet_p,
                             "reuse_line_p": reuse_line_p}))
            quiet_p = False             # This only applies this regexp.
            reuse_line_p = False        # This only applies this regexp.
            continue
        # <: add new options here :>
    grep_files(args, regexps)
