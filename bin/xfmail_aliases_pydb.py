

from alias_list_pydb import *


#
# override the default emitters...
#

def format_alias(alias):
    if alias.fullname:
        fullname = '%s ' % alias.fullname
    else:
        fullname = ''
    return '%s<%s>' % (fullname, alias.addr)
    
#
# e.g.
#@ dan
# Dan Grotefend <dgrot@atl.mindspring.com>
#
def emit_alias(alias):
    print '@ %s\n %s' % (alias.alias, format_alias(alias))
    
#
# e.g.
#@ recs
# Arnold Garlick <arnold@pacific.com>
# Beth Evancheck <beth@spica.bdt.com>
# Herb Gideon <gideon@bga.com>
# Kabir Mahadeva <kabir@alumni.princeton.edu>
# Scott Bostic <sbostic@lovetts.com>
#
def emit_list(name, list_of_aliases):
    addrs = []
    for alias in list_of_aliases:
        addrs.append(format_alias(alias))
    print '@ %s\n %s' % (name, string.join(addrs, '\n '))

set_emitters(emit_alias, emit_list)
