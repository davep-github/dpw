#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse
import dp_io

##e.g. class App_arg_action(argparse.Action):
##e.g.     def __call__(self, parser, namespace, values, option_string=None):
##e.g.         regexps = getattr(namespace, self.dest)
##e.g.         regexps.append(values)
##e.g.         setattr(namespace, self.dest, regexps)
##e.g.         setattr(namespace, "highlight_grep_matches_p", True)

def get_op(a, hex_p=True):
    if hex_p:
        a = "0x" + a
    a = eval(a)
    return a


def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. "
                         "dp_io.cdebug(<n>, fmt [, ...])")
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
    oparser.add_argument("--dec",
                         dest="hex_p",
                         default=True,
                         action="store_false",
                         help="Assume addrs are in decimal vs hex.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("addrs", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    src = get_op(argv[1], app_args.hex_p) / 4
    dst = get_op(argv[2], app_args.hex_p) / 4
    delta_inst = dst - src
    print "num inst, disregarding pipelined instructions: %8x" % (delta_inst,)

    src += 2
    delta = (dst - src)
    if delta < 0:
        dir = 'backwards'
        o3 = hex((delta) + 2**32)
    else:
        dir = 'forwards'
        o3 = hex(delta)

    print "%6s (24bit offset)" % (o3,)

if __name__ == "__main__":
    main(sys.argv)

