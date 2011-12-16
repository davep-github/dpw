
import string, re

mailing_lists = {}
aliases = {}
expanded_lists = {}
verbose = 0
trace = 1
sort_aliases = 1
sort_lists = 1

class AliasDBEntry:
    """Contains a representation of the item as it exists in the db"""
    def __init__(self, alias, name, addr_list):
        self.alias = alias
        self.name = name
        self.addr_list = addr_list

class AliasItem:
    """Simple alias container"""
    def __init__(self, db_entry, alias, addr, fullname, alias_base):
        self.db_entry = db_entry
        self.alias = alias
        self.addr = addr
        self.fullname = fullname
        self.alias_base = alias_base
        
def alias_emitter(alias):
    """Simple default emitter for aliases"""
    print '%s -> "%s" <%s>' % (alias.alias, alias.fullname, alias.addr)

def list_emitter(name, list_of_aliases):
    """Simple default emitter for alias lists"""
    print name, '=>'
    for alias in list_of_aliases:
        print '  "%s" <%s>' % (alias.fullname, alias.addr)
        

def set_emitters(aliaser, lister):
    """Set the alias and list emitters"""
    global emit_alias
    global emit_list

    emit_alias = aliaser
    emit_list = lister

#
# set up the default emitters.  really only good for testing, and
#  producing generic, human readable lists.
#
set_emitters(alias_emitter, list_emitter)
    
def print_all():
    """Print all of the aliases and then all of the expanded lists."""
    keys = aliases.keys()
    if sort_aliases:
        keys.sort()
    for key in keys:
        emit_alias(aliases[key])

    keys = expanded_lists.keys()
    if sort_lists:
        keys.sort()
    for key in keys:
        emit_list(key, expanded_lists[key])


def expand_mailing_list(db_entry, mlist):
    """Expand all entries of the alias list."""
    ret = []
    for ent in mlist:
        #
        # is this entry an alias???
        #
        v = aliases.get(ent)
        if v:
            ret.append(v)
            continue

        #
        # an already expanded list?
        #
        v = expanded_lists.get(ent)
        if v:
            ret.extend(v)
            continue

        #
        # an as yet unexpanded list ???
        #
        v0 = mailing_lists.get(ent)
        if v0:
            d = v0[0]
            v = v0[1]
            expanded_lists[ent] = expand_mailing_list(d, v)
            # print expanded_lists[ent]
            ret.extend(expanded_lists[ent])

        #
        # nothing special, just an alias
        #
        ret.append(AliasItem(db_entry, ent, ent, ent, ent))

    return ret


def expand_mailing_lists():
    for name, mlist_tuple in mailing_lists.items():
        db_entry = mlist_tuple[0]
        mlist = mlist_tuple[1]
        l = expand_mailing_list(db_entry, mlist)
        expanded_lists[name] = l


def main(database, entry):
    #
    # entry is a phone book entry.
    # fields include:
    # alias (is also the key field)
    #  an alias can be a list of alternatives separated by '|'s
    # name - full name
    # email[-xx] - various email addrs
    #  foreach email-xx, we also generate an alias-xx entry
    #
    # some entries are lists. an entry is a list if
    #  the mail field contains 1 or more commas.
    #

    # get all fields beginning with email
    emails = entry.ret_fields('^email')
        
    if not emails:
        # no email fields, not much to do.
        return
    
    alias = entry['alias']

    #
    # create entries for all email-xxx addrs
    # alias may be a list of alternations a|x|z
    #
    fullname = entry.get_item('name', '')
    db_entry = AliasDBEntry(alias, fullname, emails)
    alist = string.split(alias, '|')
    for alias in alist:
        for email_fld, addr in emails.items():
            if string.find(addr, ',') >= 0:
                # this is a list, handle it.
                mailing_lists[alias] = (db_entry, string.split(addr, ','))
                if verbose:
                    print 'encountered list, name:', alias, 'contents:', \
                          mailing_lists[alias]
            else:
                # regular entry.
                # grab the email suffix and tack it onto the end of
                # the alias and use that as the key into the alias
                # dictionary.
                # construct an alias entry and save it in the dict.
                #
                talias = alias + email_fld[5:]
                aliases[talias] = AliasItem(db_entry,
                                            talias, addr, fullname,
                                            alias)


def handle_eof(database):
    expand_mailing_lists()
    print_all()
