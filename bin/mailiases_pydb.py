
from alias_list_pydb import *

#
# override the default emitters...
#


#
# e.g.
# (define-mail-abbrev "dan" "\"Dan Grotefend\" <dgrot@atl.mindspring.com>")
#
def emit_alias(alias):
    if alias.fullname:
        fullname = '\\"%s\\" ' % alias.fullname
    else:
        fullname = ''
    print '(define-mail-abbrev "%s" "%s<%s>")' % (alias.alias,
                                                  fullname,
                                                  alias.addr)

#
# e.g.
# (define-mail-abbrev "old-gang" "bee,ben,chris,jason-rinn,lee,mark,mel,rebeca,ron ,dan,jim,scott,bbaker,brad,markc,eric,jfg-work")
#
def emit_list(name, list_of_aliases):
    mail_def = []
    mail_def.append('(define-mail-abbrev "%s" "' % name)
    sep = ''
    for alias in list_of_aliases:
        mail_def.append('%s%s' % (sep, alias.alias))
        sep = ','
    mail_def.append('")')
    print string.join(mail_def, '')
    
set_emitters(emit_alias, emit_list)
