#!/usr/bin/env python
### Time-stamp: <2020-10-09 17:59:47 davep>
#############################################################################
## @package 
##
import sys, os
import collections

UserDict = collections.UserDict
class DP_UserDict(UserDict):
    def __init__(self, *args, **kw_args):
        ## Pretty transparent
        super().__init__(self, *args, **kw_args)

##     def __setattr__(self, name, value):
##         UserDict.UserDict.__setattr__(self, name, value)

    def __getattr__(self, name):
        return UserDict.get(name)

    def can_u_c_me(self):
        print("Well, can you?")

dpu = DP_UserDict()
