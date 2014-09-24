#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.         setattr(namespace, "highlight_grep_matches_p", True) 

def flip_list(numbers, sep = "", num_per_line = 4):
    num_on_this_line = 0
    for num in numbers:
        #print "num>%s<, type: %s" % (num, type(num))
        prefix = num[0:1]
        if prefix not in ("0x", "0X"):
            num = "0x" + num
        n = eval(num)
        s = ""
        for i in range(4):
            nb = n & 0x000000ff
            s = s + ("%02x%s" % (nb, sep))
            n = n >> 8
        print s,
        num_on_this_line += 1
        if num_on_this_line >= num_per_line:
            print
            num_on_this_line = 0
    if num_on_this_line != 0:
        print

def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level.")

    oparser.add_argument("--sep",
                         dest="octet_sep",
                         type=str,
                         default="",
                         help="Set octet separator")

    oparser.add_argument("-n", "--num-per-line", "--npl",
                         dest="num_words_per_line",
                         type=int,
                         default=4,
                         help="Num 32 bit words per line.")

    oparser.add_argument("--verbose-level",
                         dest="verbose_level",
                         type=int,
                         default=-1,
                         help="Set verbose/trace level")
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
    oparser.add_argument("numbers", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."

    if len(app_args.numbers) != 0:
        flip_list(app_args.numbers, sep = app_args.octet_sep,
                  num_per_line =app_args.num_words_per_line)
    else:
        for line in sys.stdin:
            numbers = line.split()
            flip_list(numbers, sep = app_args.octet_sep,
                      num_per_line = app_args.num_words_per_line)

if __name__ == "__main__":
    main(sys.argv)

