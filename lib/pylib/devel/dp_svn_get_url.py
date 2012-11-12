#!/usr/bin/env python

import sys, os, types, re, dp_io

URL_regexp = re.compile("\s*URL:\s+(.*)$")
def get_url_from_file(file_obj_or_name):
    if type(file_obj_or_name) == types.StringType:
        opened_p = True
        file_obj = os.popen("svn info %s" % file_obj_or_name)
    else:
        file_obj = file_obj_or_name
        opened_p = False
    m = None
    while True:
        line = file_obj.readline()
        if not line:
            break
        line = line[:-1]
        m = URL_regexp.search(line)
        if m:
            break
    if opened_p:
        file_obj.close()
    if m:
        return m.group(1)
        
    return None
