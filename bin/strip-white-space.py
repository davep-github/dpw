#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, string

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.         setattr(namespace, "highlight_grep_matches_p", True)

def main(argv):
    for line in sys.stdin:
        print line.strip()

if __name__ == "__main__":
    main(sys.argv)

