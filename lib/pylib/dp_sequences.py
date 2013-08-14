#!/usr/bin/env python
# $Id: dp_sequences.py,v 1.6 2005/05/24 19:12:56 davep Exp $
#
import types, re, string
import dp_io

listlikes = (types.ListType, types.TupleType)

########################################################################
def is_listlike(var):
    return type(var) in listlikes

def list_p(l):
    return type(l) == types.ListType

def tuple_p(t):
    return type(t) == types.TupleType

def listlike_p(l_or_t):
    """Proper, but slow..."""
    return list_p(l_or_t) or tuple_p(l_or_t)

########################################################################
def mklist(*args, **keys):
    ret = []
    literal = keys.get('literal') or []
    for a in args:
        if not literal and type(a) in listlikes:
            ret.extend(a)
        else:
            ret.append(a)
    return ret
listify = mklist

########################################################################
def mktuple(*args, **keys):
    return tuple(mklist(*args))

########################################################################
def extend_list(l, new):
    if type(new) == types.ListType:
        l.extend(new)
    else:
        l.append(new)

########################################################################
def append_to_dict_of_lists(hash, key, item):
    '''Convenience function that handles adding a list item to a hash item
    (which is a list) when the hash[key] item does not exist.'''
    try:
        hash[key].append(item)
    except KeyError:
        hash[key] = [item]
append_to_hash_of_lists  = append_to_dict_of_lists

########################################################################
def extend_dict_of_lists(dict, key, items):
    '''Convenience function that handles adding a list item to a hash item
    (which is a list) when the hash[key] item does not exist.'''
    try:
        dict[key].extend(items)
    except KeyError:
        dict[key] = items

DEBUG_DEL_LIST_ITEMS = 'DEBUG_DEL_LIST_ITEMS'
########################################################################
def del_list_items(olist, *args, **keys):
    literal = keys.get('literal') or None
    #dp_io.dump_array_of_objects(olist, 'literal: %s, olist:' % literal)
    #dp_io.dump_array_of_objects(args, 'args:')
    for a in args:
        dp_io.kwdebug(DEBUG_DEL_LIST_ITEMS, 'dli(): a>%s<\n', `a`)
        if not literal and is_listlike(a):
            for rma in a:
                dp_io.kwdebug(DEBUG_DEL_LIST_ITEMS, 'dli(): rma>%s<\n', `rma`)
                dp_io.kwdebug(DEBUG_DEL_LIST_ITEMS,
                              'rma: %s(%s)\n', `olist.remove`, `a`)
                olist.remove(rma)
        else:
            dp_io.kwdebug(DEBUG_DEL_LIST_ITEMS,
                          'rm: %s(%s)\n', `olist.remove`, `a`)
            olist.remove(a)

rm_list_items = del_list_items

########################################################################
def stringize_list(lst):
    return ['%s' % (x,) for x in lst]

########################################################################
def stringized_join(lst, sep=None):     # get string.join()'s default sep
    return string.join(stringize_list(lst), sep)

########################################################################
def list_to_indented_string(lst, indent_len=2, indent_str=" "):
    return stringized_join(lst, "\n" + indent_str * indent_len)

########################################################################
def stringize_args(*args):
    return stringize_list(args)

########################################################################
def stringized_join_args(sep, *args):   # get string.join()'s default sep
    return stringized_join(args, sep)

########################################################################
def list_diff(l1, l2):
    '''Return l1 with items in l2 removed.  l2 items need not appear in l1
    but will not be returned.'''
    return [x for x in l1 if x not in l2]

########################################################################
def iter_list_diff(l1, l2):
    for x in l1:
        if x not in l2:
            yield x

########################################################################
def list_safe_get(liszt, index, default=None):
    """Pass Exception for default if you want an index exception raised."""
    if len(liszt) > index:
        return liszt[index]
    if issubclass(Exception, default):
        raise default("Index out of range: index: %s >= len(liszt): %s"
                      % (index, len(liszt)))
    return default

########################################################################
def mk_abbrev_regexp(abbrev_pat):
    """pat is"rrr*ooo" where r are required chars and o are optional.
If any optional characters are given, they must be in the same order as they
appear in the pattern.  Old VMS style."""
    p = string.find(abbrev_pat, "*")
    if p < 0:
        # Exact match requested... no * found.
        return "^%s$" % re.escape(abbrev_pat)
    prefix = abbrev_pat[:p]
    suffix = abbrev_pat[p+1:]
    regexp = prefix
    closers = ""
    for c in suffix:
        regexp = regexp + "(" + c
        closers = closers + ")?"
    return "^" + regexp + closers + "$"

########################################################################
class Arg_obj_c(object):
    """A namer object: better than x[0] and x[5]"""
    def __init__(self, **kw_args):
        for k, v in kw_args.items():
            setattr(self, k, v)

    def __iter__(self):
        return [(i[0], i[1]) for i in self.__dict__.items()].__iter__()

    def items(self):
        return self.items_v

########################################################################
def mk_abbrev_map(abbrev_pat_tuples):
    ret = []
    for abbrev_pat, mapped_info in abbrev_pat_tuples:
        ret.append((mk_abbrev_regexp(abbrev_pat), mapped_info))
        
    pass


########################################################################
def list_get_with_abbrev(map, name, default_stuff=KeyError):
    """Get a tuple (abbrev_pat, stuff) from a list of tuples.
abbrev_pat can be a single string or a list of them.
Return stuff. See `mk_abbrev_regexp' for abbrev_pat format.
"""
    for abbrev_pat, stuff in map:
        abbrev_pats = mklist(abbrev_pat)
        for pat in abbrev_pats:
            m = re.match(mk_abbrev_regexp(pat), name)
            if m:
                return stuff
    if default_stuff == Exception:
        raise KeyError("nothing matches name>%s<" % name)
    return default_stuff

########################################################################
def list_intersection(l1, l2):
    """Return intersection of elements in l1 and l2 in no particular order."""
    ret = {}
    for le in l1:
        if le in l2:
            ret[le] = 1
    return ret.keys()

def maybe_add_to_list(in_list, element):
    """Add element to LIST iff ELEMENT is not in LIST."""
    try:
        in_list.index(element)
        pass
    except ValueError:
        in_list.append(element)

def maybe_add_list_to_list(in_list, add_from_list):
    for element in add_from_list:
        maybe_add_to_list(in_list, element)

def move_from_list(from_list, str, regexp_p=False, start=0, end=True,
                   remove_prefix_p=False, return_prefix=""):
    pred = None
##len     if False and regexp_p:              # Problems with length of prefix.
##len         pass
##len         def regexp_pred(element, regexp, start, end):
##len             if end is True:
##len                 end = len(element)
##len             element = element[start:end]
##len             return regexp.search(regexp, element)
##len         pred = regexp_pred
##len     else:
    def str_pred(element, str, start, end):
        if end is True:
            end = len(element)
        ret = element.find(str, start, end)
        if ret == -1:
            ret = None
        return ret
    pred = str_pred

    print pred
    to_list = []
    remainder_list = []
    str_len = len(str)
    for element in from_list:
        print "element>%s<, str>%s<, start>%s<, end>%s<" % (element, str, start, end)
        if pred(element, str, start, end) != None:
            if remove_prefix_p:
                if end is True:
                    element_len = len(element)
                else:
                    element_len = end
                print "element>%s<, element_len>%s<, start>%s<, str>%s<, str_len>%s<" % (element, element_len, start, str, str_len)
                element = return_prefix + element[str_len:element_len]
            print "element>%s<" % (element,)
            to_list.append(element)
        else:
            remainder_list.append(element)
    return (remainder_list, to_list)

