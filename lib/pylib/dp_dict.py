#!/usr/bin/env python
### Time-stamp: <08/07/29 17:53:10 davep>
#############################################################################
## @package 
##
import sys, os
import UserDict

class DP_UserDict(UserDict.UserDict):
    def __init__(self, *args, **kw_args):
        ## Pretty transparent
        UserDict.UserDict.__init__(self, *args, **kw_args)

##     def __setattr__(self, name, value):
##         UserDict.UserDict.__setattr__(self, name, value)        

    def __getattr__(self, name):
        return UserDict.UserDict.get(name)
        
dpu = DP_UserDict()    
