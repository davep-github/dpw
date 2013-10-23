#!/usr/bin/env python

import sys, os
import argparse

class App_arg_action_add_regexp_and_highlight(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        regexps = getattr(namespace, self.dest)
        regexps.append(values)
        setattr(namespace, self.dest, regexps)
        setattr(namespace, "highlight_grep_matches_p", True) 

def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
                         dest="debug_level",  # Becomes `dest'
                         type=int,
                         default=0,
                         help="Set debug level")
    oparser.add_argument("--quiet", "-q",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
    oparser.add_argument("--hgrep", "--hregexp", "--hmatch",
                         dest="regexp_patterns", default=[],
                         action=App_arg_action_add_regexp_and_highlight,
                         help='Grep for these patterns and highlight.')

    # ...

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."


if __name__ == "__main__":
    main(sys.argv)

