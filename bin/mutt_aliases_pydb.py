
from alias_list_pydb import *


#
# override the default emitters...
#

def format_alias(alias):
    if alias.fullname:
        fullname = '"%s" ' % alias.fullname
    else:
        fullname = ''
    return '%s<%s>' % (fullname, alias.addr)
    

#
# e.g.
# alias dan "Dan Grotefend" <dgrot@atl.mindspring.com>
#
def emit_alias(alias):
    print 'alias %s %s' % (alias.alias, format_alias(alias))
#
# e.g.
# alias jnj "Jimmy Mattison" <James.Mattison@ca.com>, "Joanne Mattison" <Joanne.Mattison@East.Sun.Com>, "The Mattisons at Home" <mattisjo@yahoo.com>
#
def emit_list(name, list_of_aliases):
    addrs = []
    for alias in list_of_aliases:
        addrs.append(format_alias(alias))
    print 'alias %s %s' % (name, string.join(addrs, ', '))


set_emitters(emit_alias, emit_list)
