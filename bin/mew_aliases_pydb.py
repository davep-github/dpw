
from alias_list_pydb import *

#
# override the default emitters...
#

def format_alias(alias):
    if alias.fullname:
        fullname = '"%s" ' % alias.fullname
    else:
        #
        # mh gets confused by the < in the addr if nothing
        # comes before it
        # so stick something sensible there.
        #
        fullname = '"%s" ' % alias.alias
    return '%s<%s>' % (fullname, alias.addr)
    

#
# mew alias, 2nd format
# e.g.
# kazu	kazu@mew.org, kazu@iijlab.net	Kazu-kun  "Kazuhiko Yamamoto"
#
def emit_alias(alias):
    if alias.fullname:
        fullname = alias.fullname
    else:
        fullname = alias.alias

    if alias.alias == alias.alias_base:
        # main entry, use all addrs
        #print 'vals:', alias.db_entry.addr_list.values()
        addr = string.join(alias.db_entry.addr_list.values(), ', ')
    else:
        addr = alias.addr
    print '%s %s %s "%s"' % (alias.alias, addr,
                             alias.alias_base, fullname)
    
#
# e.g.
#rawhiders: scalable,\
#        sokolov,\
#        pjm
def emit_list(name, list_of_aliases):
    addrs = []
    for alias in list_of_aliases:
        addrs.append(alias.alias)
    print '%s: %s' % (name, string.join(addrs, ', '))

set_emitters(emit_alias, emit_list)
