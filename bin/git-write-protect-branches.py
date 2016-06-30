#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse
import dp_io, dp_git_helper_lib, dp_utils

debug_file = sys.stderr
verbose_file = sys.stderr
warning_file = sys.stderr

BROKEN_PIPE_RC = 1
IOERROR_RC = 1

# if not in FORBIDDEN_BRANCHES and (not ALLOWED_BRANCHES or in ALLOWED_BRANCHES)
# @todo XXX Should we make this a list of regexps?  "^...$" makes a string match.
FORBIDDEN_BRANCHES = []
ALLOWED_BRANCHES = []

FORBIDDEN_BRANCH_REGEXPS = []
ALLOWED_BRANCH_REGEXPS = []

dp_utils.extend_path_list_from_env(FORBIDDEN_BRANCHES, "GIT_FORBIDDEN_BRANCHES")
dp_utils.extend_path_list_from_env(ALLOWED_BRANCHES, "GIT_ALLOWED")

def is_forbidden_p(branch):
    return ((branch in FORBIDDEN_BRANCHES)
            or
            (match_a_regexp(FORBIDDEN_BRANCH_REGEXPS, branch)))

def is_allowed_p(branch):
    # If there is nothing listed, then we are allowed
    if (not (ALLOWED_BRANCHES_REGEXPS and ALLOWED_BRANCHES)):
        return True

    if branch in ALLOWED_BRANCHES:
        return True

    if dp_utils.match_a_regexp(ALLOWED_BRANCH_REGEXPS):
        return True

    return False

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
                         help="Set verbose/trace level. Use with, e.g. "
                         "dp_io.ctracef(<n>, fmt [, ...])")
    oparser.add_argument("-b", "--branch",
                         dest="branch",
                         type=str,
                         default=None,
                         help="Branch to check, else current-branch.")
    oparser.add_argument("-r", "--git-repo", "--repo",
                         dest="git_repo",
                         type=str,
                         default=None,
                         help="Repo of interest.")
    oparser.add_argument("-q", "--quiet",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
    # For non-option args
    oparser.add_argument("non_option_args", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print "I am being quiet."
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable=True)

    if app_args.git_repo:
        os.chdir(app_args.git_repo)

    branch = app_args.branch
    if not branch:
        branch = dp_git_helper_lib.git_current_branch()

    dp_io.vcprintf(2, "FORBIDDEN_BRANCHES>{}<\n", FORBIDDEN_BRANCHES)
    dp_io.vcprintf(2, "ALLOWED_BRANCHES>{}<\n", ALLOWED_BRANCHES)

    # Forbidden if:
    # in FORBIDDEN_BRANCHES
    # or (ALLOWED_BRANCHES and not in ALLOWED_BRANCHES)
    if ((branch in FORBIDDEN_BRANCHES)
        or
        (ALLOWED_BRANCHES and (branch not in ALLOWED_BRANCHES))):
        print >>sys.stderr
        print >>sys.stderr, " You are trying to commit on the {} branch.".format(branch)
        print >>sys.stderr, " And it is NOT to be committed to."
        print >>sys.stderr
        print >>sys.stderr, " If you insist, force the commit by adding --no-verify to the command."
        print >>sys.stderr
        return 1
    else:
        return 0

if __name__ == "__main__":
    # try:... except: nice for filters.
    sys.exit(main(sys.argv))
