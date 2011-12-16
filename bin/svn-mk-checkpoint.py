#!/usr/bin/env python

import os, sys, sre, string, getopt
import host_info

# Simple svn checkpointer.
# (Optional message -m xxx.  -m=- --> go thru editor.
# Else 'useful checkpoint.'
# Manual:
# svn copy file:///usr/yokel/svn/my-world/bin \
#         file:///usr/yokel/svn/my-world/bin-branches/checkpoint.$(dp-std-date)
#
# file:///usr/yokel/svn/my-world is essentially my root
# and file:///usr/yokel/svn/my-world/bin is ~/bin
# and file:///usr/yokel/svn/my-world/lisp is ~/lisp
#
# svn branches are in:
# file:///usr/yokel/svn/my-world/<module>-branches
# So, subtract $HOME, from $PWD --> $module (most likely)
# svn_module_url=$SVN_ROOT/$module
# confirm.  If module exists, def Y, else change. Allow (yes, no, change)
# Branches URL is svn_branch_url=${svn_module_url}-branches
# svn_checkpoint_url=${svn_branch_url}/checkpoint.$(dp-std-date)
# if $svn_branch_dir isn't present:
#    confirm w/user
#    (svn mkdir)
# 
# svn copy  ${svn_module_url} ${svn_checkpoint_url}
#
HOME = os.environ['HOME']
SVN_ROOT = 

def make_checkpoint():
    module = os.environ['PWD'][len(HOME)+1:]
    
