#!/usr/bin/env python
#
# Purify Path Name.  Make path names more digestible for bash, et.al.
#

import os, sys, string

good_chars = string.letters + string.digits + """.-_()[]& ,'"""
not_good_repl = '-'
bad_chars = ''':?\\";~'''
bad_char_repl = '-'
low_bad = ord(' ')
hi_bad = 127

ffn_translation_table = ''
for i in range(0, 256):
    c = chr(i)
    if (i < low_bad) or (i > hi_bad):
        c = '?'
    elif c in bad_chars:
        c = bad_char_repl
    else:
        if c not in good_chars:
            c = not_good_repl
    ffn_translation_table = ffn_translation_table + c
    
########################################################################
def purifile_name(fname):
    return string.translate(fname, ffn_translation_table)
        

#
# NB! there is a problem if two leaf paths share a common path and the
# common path needs to be renamed.  When the second path is fixed, it
# will get errors while trying to rename the common part.
# IDEA: if the new name exists and the old one doesn't, skip this step.
#
def purify_path_name(path, stop_at=False, verbosity=0):
    if purifile_name(path) == path:
        if verbosity > 0:
            print 'this path is pure!'  # of poltergeists.
        return
    
    np = os.path.normpath
    jp = os.path.join
    if stop_at:
        stop_at = np(stop_at)
    d_comps = string.split(path, '/')
    #print 'len:', len(d_comps)
    while len(d_comps) > 1:
        if stop_at and (np(path) == stop_at):
            break
        ld = d_comps[-1]                # grab last dir component
        d_comps = d_comps[:-1]          # trim last dir component
        fld = purifile_name(ld)         # fix the last dir component
        path = string.join(d_comps, '/') # dir in which last component lives
        frm = np(jp(path, ld ))
        to  = np(jp(path, fld))
        print ' frm>%s<\n  to>%s<' % (frm, to)
        if frm != to:
            ###os.rename(frm, to)
            print 'Renaming'
        else:
            print "No need to rename."


def purify_path_names(path_list, stop_at=False, verbosity=0):
    for p in path_list:
        purify_path_name(p, stop_at, verbosity)

if __name__ == "__main__":
    ## !<@todo XXX parse for stop_at and verbosity.
    stop_at = False
    verbosity = 0
    purify_path_names(sys.argv[1:], stop_at, verbosity)

    sys.exit(0)
