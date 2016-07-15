#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse
import dp_io, dp_git_helper_lib, dp_utils
opath = os.path

debug_file = sys.stderr
verbose_file = sys.stderr
warning_file = sys.stderr

BROKEN_PIPE_RC = 1
IOERROR_RC = 1

FORBIDDEN_BRANCHES_FILE_NAME = "read-only-branches"

# if not in FORBIDDEN_BRANCHES and (not ALLOWED_BRANCHES or in ALLOWED_BRANCHES)
# @todo XXX Should we make this a list of regexps?  "^...$" makes a string match.
FORBIDDEN_BRANCHES = []
ALLOWED_BRANCHES = []

FORBIDDEN_BRANCH_REGEXPS = ["[._,-]NC$", "^NC[._,-]"]
ALLOWED_BRANCH_REGEXPS = []

dp_utils.extend_list_from_env_path(FORBIDDEN_BRANCHES, "GIT_FORBIDDEN_BRANCHES")
dp_utils.extend_list_from_env_path(ALLOWED_BRANCHES, "GIT_ALLOWED")
local_branches_file = dp_git_helper_lib.git_dotgit()
if not local_branches_file:
    print >>sys.error, "Cannot git repo root"
    sys.exit(1)
local_branches_file = opath.join(local_branches_file, "..",
                                 FORBIDDEN_BRANCHES_FILE_NAME)
LOCAL_FORBIDDEN_BRANCHES = dp_utils.list_from_file_lines(local_branches_file)

FORBIDDEN_BRANCHES.extend(LOCAL_FORBIDDEN_BRANCHES)

def forbidden_p(branch):
    return ((branch in FORBIDDEN_BRANCHES)
            or
            (dp_utils.match_a_regexp(FORBIDDEN_BRANCH_REGEXPS, branch)))

def allowed_p(branch):
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
    oparser.add_argument("--verbose-level", "--vl",
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

    dp_io.ctracef(2, "FORBIDDEN_BRANCHES>%s<\n", FORBIDDEN_BRANCHES)
    dp_io.ctracef(2, "ALLOWED_BRANCHES>%s<\n", ALLOWED_BRANCHES)
    dp_io.ctracef(2, "FORBIDDEN_BRANCH_REGEXPS>%s<\n", FORBIDDEN_BRANCH_REGEXPS)
    dp_io.ctracef(2, "ALLOWED_BRANCH_REGEXPS>%s<\n", ALLOWED_BRANCH_REGEXPS)
    dp_io.ctracef(2, "LOCAL_FORBIDDEN_BRANCHES>%s<\n", LOCAL_FORBIDDEN_BRANCHES)
    dp_io.ctracef(2, "local_branches_file>%s<\n", local_branches_file)

    if app_args.git_repo:
        os.chdir(app_args.git_repo)

    branch = app_args.branch
    if not branch:
        branch = dp_git_helper_lib.git_current_branch()
    dp_io.vcprintf(2, "branch>{}<\n", branch)
    
    # Forbidden if:
    # in FORBIDDEN_BRANCHES
    # or (ALLOWED_BRANCHES and not in ALLOWED_BRANCHES)
    if (forbidden_p(branch)
        or
        (ALLOWED_BRANCHES and not allowed_p(branch))):
        print >>sys.stderr
        print >>sys.stderr, " ! COMMIT PROTECTED BRANCH !"
        print >>sys.stderr
        print >>sys.stderr, " You are trying to commit on the `{}' branch.".format(branch)
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
