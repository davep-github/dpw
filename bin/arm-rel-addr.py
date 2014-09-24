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
        print "a>%s<" % (a,)
        prefix = a[0:2]
        print "prefix>%s<" % (prefix,)
        if prefix not in ("0x", "0X"):
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
    oparser.add_argument("-b", "--make-branch",
                         dest="make_branch_p",
                         default=False,
                         action="store_true",
                         help="Add the branch op code.")
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
    oparser.add_argument("addr", nargs=2)

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

#    for i in range(len(app_args.addrs)):
#        print "argv[{}]>{}<".format(i, app_args.addrs[i])
#    sys.exit(99)

    addrs = app_args.addr
    src = get_op(addrs[0], app_args.hex_p) / 4
    dst = get_op(addrs[1], app_args.hex_p) / 4
    delta_inst = dst - src
    abs_delt = abs(delta_inst)
    if delta_inst < 0:
        sign = '-'
    else:
        sign = ''
    print "num inst, sans pipe: %s0x%08x (%d)" % (sign, abs_delt, delta_inst)

    src += 2
    delta = (dst - src)
    if delta < 0:
        dir = 'backwards'
        delta = delta + 2**32
    else:
        dir = 'forwards'
        # delta = delta
    delta = delta & 0x00ffffff
    o3 = hex(delta)

    print "0x%08x (low 24 bits)" % (delta,)
    if app_args.make_branch_p:
        inst = 0xea000000 + delta
        print "branch: 0x%08x" % (inst,)


if __name__ == "__main__":
    main(sys.argv)

