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

def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. dp_io.cdebug()")
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
    oparser.add_argument("-e", "--cmd", "--exec", "--program", "--prog",
                         dest="cmd",
                         default="",
                         type=str,
                         help="Run input lines with this command.")
    oparser.add_argument("-p", "--prompt",
                         dest="prompt",
                         default="Press enter to exec",
                         type=str,
                         help="Prompt with this string.")
    oparser.add_argument("-H", "--header",
                         dest="header",
                         default="",
                         type=str,
                         help="Print this before the prompt.")
    oparser.add_argument("--header-full",
                         dest="header_full_p",
                         default=False,
                         action="store_true",
                         help="Print this before the prompt.")
    oparser.add_argument("-S", "--no-show-cmd", "--hide-cmd", "--no-show",
                         dest="show_cmd_p",
                         default=True,
                         action="store_false",
                         help="Show command in prompt string.")
    oparser.add_argument("--yes", "--auto", "--auto-yes", "--all", "--doit",
                         dest="auto_yes_p",
                         default=False,
                         action="store_true",
                         help="Don't ask. Kind of against the philosophy of"
                         " the program, but it can be useful to just add"
                         " --auto to command you'd like to start doing"
                         " unconditionally.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("input_files", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level > 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    cmd = app_args.cmd
    if cmd:
        cmd = cmd + " "
        
    # Slurp up the lines
    lines = []
    while True:
        input_line = sys.stdin.readline()
        if not input_line:
            break
        dp_io.cdebug(1, "input_line>{}<\n", input_line)
        lines.append(input_line[:-1])

    kb = open("/dev/tty", 'r')
    header = app_args.header
    for line in lines:
        dp_io.cdebug("line>{}<\n", line)
        cmd_line = cmd + line
        if not app_args.auto_yes_p:
            if app_args.show_cmd_p:
                prompt = app_args.prompt + "[" + cmd_line + "]"
            else:
                prompt = app_args.prompt
            prompt = prompt + ": "
            if app_args.header_full_p:
                header = len(prompt) * "="
            if header:
                sys.stdout.write(header + "\n")
            sys.stdout.write(prompt)
            input_line = kb.readline()
            if not input_line:              # ^D
                break
            else:
                input_line = input_line[:-1]
                if input_line in ("q", "quit", "x", "exit", "bye"):
                    break
                elif input_line in ("n", "next", "skip", "s",
                                  "iter", "iterate"):
                    continue
                elif input_line in ("", "y", "yes", "exec", "run"):
                    pass
                else:
                    dp_io.eprintf("Unrecognized response>{}<\n", input_line)
                    sys.exit(1)
        dp_io.cdebug(1, "cmd_line>{}<\n", cmd_line)
        os.system(cmd_line)
        dp_io.cdebug("input_line>{}<\n", input_line)

if __name__ == "__main__":
    main(sys.argv)


  
