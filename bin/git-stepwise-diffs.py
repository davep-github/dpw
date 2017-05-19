#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys, errno
import argparse
import dp_io, dp_utils, dp_sequences
import dp_git_helper_lib

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

def process_input_fobj(fobj, app_args):
    commit_list0 = dp_utils.list_from_fobj_lines(fobj)

    commit_list0.reverse()
    commit_list = commit_list0 # [ s.split()[0] for s in commit_list0 ]

    left_commits = []
    right_commits = []
    left_commit_msgs = []
    right_commitmsgs = []
    num_lines = len(commit_list)
    for i in range(num_lines):
        if i + 1 >= num_lines:
            break
        left_commits.append(commit_list[i])
        right_commits.append(commit_list[i+1])
    print "WTGDFF?"
    dp_io.cdebug(2, "\nleft:\n%s\n<<<<<<<<<<<",
                 dp_sequences.list_to_indented_string(left_commits, 0))
    dp_io.cdebug(2, "\nright:\n%s",
                 dp_sequences.list_to_indented_string(right_commits, 0))
    for i in range(len(left_commits)):
        l = left_commits[i].split()[0]
        r = right_commits[i].split()[0]
        command = "git {} {} {} {} {}".format(app_args.git_diff_cmd,
                                           app_args.git_diff_args,
                                           l, r,
                                           dp_sequences.stringized_join(
                                               app_args.files_to_diff))
        if app_args.show_commit_p:
            dp_io.printf("====================================\n")
            dp_io.printf("Prev: %s: %s\n", l,
                         dp_sequences.stringized_join(left_commits[i].split()[1:]))
            print "Curr: {}: {}".format(
                r,
                dp_sequences.stringized_join(right_commits[i].split()[1:]))

        if app_args.query_execution_p:
            print "Run {} [Y/n/q]? ".format(command),
            # NB: This does not work if we're reading our input from stdin.
            ans = sys.stdin.readline()
            if ans and ans[-1] == '\n':
                ans = ans[:-1]
            dp_io.cdebug(1, "ans>{}<\n", ans)
            if ans and ans in "qQxX":
                sys.exit(0)
            # We want <return> --> y
            # Just <return> returns "".
            # and "" is in "yY"
            # So <return> --> y.
            if ans not in "yY":
                continue
        print "app_args.dry_run_p:", app_args.dry_run_p
        sys.exit(99)

        if app_args.dry_run_p:
            print "{}{}".format("{-}", command)
            continue
        os.system(command)
    
def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug", "--dl",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. "
                         "dp_io.cdebug(<n>, fmt [, ...])")
    oparser.add_argument("--verbose-level", "--vl",
                         dest="verbose_level",
                         type=int,
                         default=-1,
                         help="Set verbose/trace level. Use with, e.g. "
                         "dp_io.ctracef(<n>, fmt [, ...])")
    oparser.add_argument("-q", "--quiet",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
    oparser.add_argument("-f", "--ford", "--file",
                         dest="files_to_diff", default=[],
                         type=str,
                         action="append",
                         help="A list of files and/or dirs to diff.")
    oparser.add_argument("-d", "--diff", "--diff-tool", "--differ",
                         dest="git_diff_cmd", default="dtm",
                         type=str,
                         help="What diff tool to run.")
    oparser.add_argument("--diff-arg", "--diff-args", "--darg", "--dargs",
                         "--da", "--das",
                         dest="git_diff_args", default=[],
                         type=str,
                         action="append",
                         help="A list of args to pass diff.")
    oparser.add_argument("-a", "--query", "--ask",
                         dest="query_execution_p",
                         default=False,
                         action="store_true",
                         help="Should the user be asked to run the program.")
    oparser.add_argument("-n", "--just-show", "--dry-run",
                         dest="dry_run_p",
                         default=False,
                         action="store_true",
                         help="Should the user be asked to run the program.")
    oparser.add_argument("-v", "--show-cmd",
                         dest="show_cmd_p",
                         default=False,
                         action="store_true",
                         help="Show the program that is going to be run.")
    oparser.add_argument("-C", "--no-show-commit",
                         dest="show_commit_p",
                         default=True,
                         action="store_false",
                         help="Do not show commit's one line summary.")
                         

##e.g.     oparser.add_argument("--app-action", "--aa",
##e.g.                          dest="app_action_stuff", default=[],
##e.g.                          action=App_arg_action,
##e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args
    oparser.add_argument("non_option_args", nargs="*")

    app_args = oparser.parse_args()

    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable_debugging_p=True)

    dp_io.cdebug(2,"files_to_diff:\n>{}<\n".format(
        dp_sequences.list_to_indented_string(app_args.files_to_diff, 0, sep=' ')))

    if app_args.git_diff_args:
        git_diff_args = dp_utils.list_from_path_like_lines(app_args.git_diff_args,
                                                           sep=',', stringize_p=True)
        dp_io.cdebug(1, "git_diff_args>{}<\n", git_diff_args)
        git_diff_args = dp_sequences.stringized_join(git_diff_args)
        dp_io.cdebug(1, "git_diff_args>{}<\n", git_diff_args)
        app_args.git_diff_args = git_diff_args
    if app_args.non_option_args:
        for f in app_args.non_option_args:
            fobj = open(f)
            process_input_fobj(fobj, app_args)
            fobj.close()
    else:
        process_input_fobj(sys.stdin, app_args)

if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        sys.exit(main(sys.argv))
    except IOError, e:
        # We're quite often a filter reading or writing to a pipe.
        dp_io.cdebug(1, "e: %s, e.errno: %s\n", e, e.errno)
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print >>sys.stderr, ":Broken PIPE:"
            sys.exit(BROKEN_PIPE_RC)
        print >>sys.stderr, "IOError>%s<" % (e,)
        sys.exit(IOERROR_RC)

