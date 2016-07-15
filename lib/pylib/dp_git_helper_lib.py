#!/usr/bin/env python

import os, sys
import argparse
import dp_io, dp_utils
opath = os.path

## Make error check finer grained.
def git_current_branch(dir = None):
    try:
        old_cwd = None
        if dir:
            old_cwd = dp_utils.realpwd()
            os.chdir(dir)

        gcb = dp_utils.bq("git rev-parse --abbrev-ref=strict HEAD")

        if old_cwd:
            os.chdir(old_cwd)

        return gcb
    except:
        return False

def git_dotgit():
    dg = dp_io.bq("git-dotgit")
    if dg and dg[-1] == "\n":
        dg = dg[:-1]
    return dg
    
