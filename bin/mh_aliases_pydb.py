
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
# e.g.
# dan: "Dan Grotefend" <dgrot@atl.mindspring.com>
#
def emit_alias(alias):
    print '%s: %s' % (alias.alias, format_alias(alias))
#
# e.g.
#rawhiders: scalable,\
#        sokolov,\
#        pjm
def emit_list(name, list_of_aliases):
    addrs = []
    for alias in list_of_aliases:
        addrs.append(format_alias(alias))
    print '%s: %s' % (name, string.join(addrs, ',\\\n\t'))
                      

set_emitters(emit_alias, emit_list)
