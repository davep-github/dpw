#!/usr/bin/env python

import sys, os

# !<@todo XXX Use git format for now, but make this handle other formats.

def git_exclude_to_pcre(line):
    # This is a glob and in addition xxx/ --> xxx/*
    if (re.search("^\s*#", line)):
        return None
    prefix, pcre, suffix = glob_to_pcre(line)
    if (pcre[0] == "/"):
        pcre = ".*" + pcre
    if (pcre[-1] == "/"):
        pcre = pcre + ".*"
    return prefix + pcre + suffix

def main(argv):
    import getopt
    opt_string = "f:s"
    # File object and flag telling us if we need to close the file.
    # We can just go ahead and read stdin by default because it'll just EOF
    # immediately if no redirection has been done.
    # But give the ability to suppress this action.
    files_to_read = [(sys.stdin, False)]
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-s':
            files_to_read = files_to_read[1:]
            continue
        if o == '-f':
            # Handle opt
            files_to_read.append(open(v, "r"), True)
            continue

    for arg in args:
        # Handle arg
        git_exclude_to_pcre(arg)

    for f, close_p in files_to_read:
        while True:
            l = f.readline()
            if not l:
                break
            l = l[0:-1]
            git_exclude_to_pcre(l)
        if (close_p):
            f.close()

if __name__ == "__main__":
    main(sys.argv)


