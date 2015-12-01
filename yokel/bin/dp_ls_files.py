#!/bin/env python

#
# return list of files in a directory allowing list to be filtered by
# an exclude file and an include file
#
# exclude(include(glob)) -- if include given first as parameter
# or
# include(exclude(glob)) -- if exclude given first as parameter
# exclude * or include * can be used to control access to entire dir
# (sans dirs)

import sys, os, re
import glob, fnmatch

class DirList:
    def __init__(self, glob, incl_file=None, excl_file=None):
        # incl == none && excl == none ==> incl all
        self.glob = glob or '*'
        self.incl_file = incl_file
        self.excl_file = excl_file

    def filter(names, incl_match, filter_patterns=None):
        if not filter_patterns:
            return names
        ret_list = []
        for pat in filter_patterns:
            
            
        
    def list(self):
        # glob.glob('./[0-9].*')
        # get files in dir matching self.glob w/ glob.glob(self.glob)

        # use fnmatch.fnmatch() to see if lines from incl/excl match
        # files returned by glob.glob()
        flist = glob.glob(self.glob)
        flist = self.filter2(self.filter1(flist))
        
        
        
        

        

