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
    oparser.add_argument("--no-prompt",
                         dest="print_prompt_p",
                         default=True,
                         action="store_false",
                         help="Don't show a prompt.")
    oparser.add_argument("--bare",
                         dest="bare_p",
                         default=False,
                         action="store_true",
                         help="Don't show anything.")
    oparser.add_argument("--yes", "--auto", "--auto-yes", "--all", "--doit",
                         "--no-ask", "--ask-not", "--dont-ask",
                         dest="auto_yes_p",
                         default=False,
                         action="store_true",
                         help="Don't ask. Kind of against the philosophy of"
                         " the program, but it can be useful to just add"
                         " --auto to command you've been choosy about that"
                         " you'd now like to start doing unconditionally.")
##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("cmd_args", nargs="+")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level > 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    if len(app_args.cmd_args) < 1:
        dp_io.eprintf("A command name -- and possible args -- are required.\n")
        sys.exit(1)

    cmd = " ".join(app_args.cmd_args) + " "
    dp_io.cdebug(1, "cmd>{}<\n", cmd)

    if app_args.bare_p:
        app_args.auto_yes_p = True
        app_args.show_cmd_p = False
        app_args.header_full_p = False
        app_args.header = None
        app_args.print_prompt_p = False
        

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
    quit_p = False
    for line in lines:
        cont_p = True
        while cont_p:
            cont_p = False
            dp_io.cdebug("line>{}<\n", line)
            cmd_line = cmd + line
            if app_args.show_cmd_p:
                prompt = app_args.prompt + ": [{}]".format(cmd_line)
            else:
                prompt = app_args.prompt
            prompt = prompt + ": "
            if app_args.header_full_p:
                header = len(prompt) * "="
            if header:
                dp_io.printf("{}\n", header)
            if app_args.print_prompt_p:
                dp_io.printf("{}", prompt)
            if app_args.auto_yes_p:
                if not app_args.bare_p:
                    dp_io.printf("\n")
                input_line = "\n"
            else:
                input_line = kb.readline()
                if not input_line:              # ^D
                    quit_p = True
                    dp_io.printf("\n")
                    break
                quit_keywords = ("Quit", ("^d", "q", "quit", "x", "exit", "bye"))
                skip_keywords = ("Skip",
                                 ("n", "next", "skip", "s", "iter", "iterate"))
                exec_keywords = ("Exec", ("<enter>", "y", "yes", "exec", "run"))
                input_line = input_line[:-1]
                if input_line in ("h", "help", "?", "wtf"):
                    if input_line in ("h", "help", "?", "wtf"):
                        for blurb, kwl in (skip_keywords,
                                           quit_keywords,
                                           exec_keywords):
                            dp_io.printf("{}: {}\n", blurb, ", ".join(kwl))
                        cont_p = True
                        continue
                elif input_line in quit_keywords[1]:
                    dp_io.printf('"{}" --> Quitting.\n', input_line)
                    quit_p = True
                    break
                elif input_line in skip_keywords[1]:
                    dp_io.printf('"{}" --> Skipping.\n', input_line)
                    continue
                elif input_line in ("", ) + exec_keywords[1]:
                    pass
                else:
                    dp_io.eprintf("Unrecognized response>{}<\n", input_line)
                    sys.exit(1)
            dp_io.cdebug(1, "cmd_line>{}<\n", cmd_line)
            os.system(cmd_line)
            dp_io.cdebug("input_line>{}<\n", input_line)
        if quit_p:
            break
        
if __name__ == "__main__":
    main(sys.argv)


  
