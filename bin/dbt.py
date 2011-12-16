"""
class Entry
A general purpose container for flexibly structured small data bases.
"""

import string, re, types, os, sys, imp

pydb_dir=''

class PythonDataBase:
    def __init__(self, entriesxx=[], id='unspecified'):
        self.entries = []
        self.entries.extend(entriesxx)
        self.keys = {}

    def __getitem__(self, key): return self.keys[key]

    def dump(self, title=''):
        print 'dumping db(%s): %s\nvvvvvvvvvvvvvvvvvvvvvvvvvv' % (self,title)
        for e in self.entries:
            print 'e:', e
            e.dump()
        print '^^^^^^^^^^^^^^^^^^^^^^^^^^'
            

    ###############################################################
    def items_as_list(self):
        return self.entries

    ###############################################################
    def grep_fields(self, field_pattern=None, val_pattern=None):
        if type(field_pattern) == types.StringType:
            rex = re.compile(field_pattern)
        else:
            rex = field_pattern
        if type(val_pattern) == types.StringType:
            val_rex = re.compile(val_pattern)
        else:
            val_rex = val_pattern
        ret = []
        for rec in self.items_as_list():
            r = rec.grep_fields(rex, val_rex)
            if r:
                ret.append(r)
        return ret

    ###############################################################
    def get(self, key, field=None, default=AttributeError):

        # try for item by key in keys.
        # if found, we're done
        ret = self.keys.get(key, None)
        if ret:
            return ret

        # otherwise, check fields matching field for values matching key
        # if found, we're done

        # return default.  if default is AttributeError, raise that
        
        if default == AttributeError:
            try:
                return self.items[item]
            except KeyError:
                raise AttributeError
        else:
            return self.items.get(item, default)

    ###############################################################
    def join(self, new_db):
        self.entries.extend(new_db.entries)

    ###############################################################
    def add(self, key=None, dat=None, ref=None, kef=None):
        if dat == None:
            if type(key) != types.DictType:
                raise 'Single arg must be a dictionary'
            dat = key
            key = None

        entry = Entry(dat)
        if ref:
            entry.add_refs(ref)
        if kef != None:
            key=entry.get_item(kef)
        if key != None:
            self.keys[key] = entry
        self.entries.append(entry)


###############################################################
class Entry:
    def __init__(self, *pargs, **kargs):
        """__init__(self, *list, **items):
        Add all positional parameters in *list to the object's items element.
         Each element of *list must be a dictionary.
        Add all the key/val pairs in items to the object's items element."""
        # print '*pargs>%s<' % (pargs,)
        # print '**kargs>%s<' % (kargs,)
        self.items = {}
        for i in pargs:
            self.items.update(i)
        self.items.update(kargs)
        # print 'self.items>%s<' % self.items
        self.references = []

    ###############################################################
    def __getitem__(self, key): return self.items[key]

    ###############################################################
    def add_refs(self, refs):
        if type(refs) != types.ListType and type(refs) != types.TupleType:
            refs = (refs,)
        self.references.extend(refs)
        
    ###############################################################
    def old__init__(self, **items):
        """__init__(self, **items):
        add all the key/val pairs in items to the object's items element."""
        self.items = items
        
    ###############################################################
    def add_items(self, **items):
        """add_items(self, **items):
        Add the items in **items to the object's items element."""

        for k in items.keys():
            if string.find(k, '|') > -1:
                for k2 in split(s, '|'):
                    self.items[k2] = items[k2]
            else:
                self.items.update(items)

    ###############################################################
    def grep_fields(self, pat=None, vpat=None, prefix=''):
        """
        grep_fields(selfm pat=None, vpat=None):
        search the entry for field names that match pat and field values
        that match vpat.
        Pats may be: strings w/regexps, compiled regexps, None
        If None --> match all (faster than matching .*)
        """
        if type(pat) == types.StringType:
            field_rex = re.compile(pat)
        else:
            field_rex = pat
        if type(vpat) == types.StringType:
            val_rex = re.compile(vpat)
        else:
            val_rex = vpat
        for key in self.items.keys():
            if not field_rex or field_rex.search(key):
                if not val_rex or val_rex.search(self.items[key]):
                    return self

        for ref in self.references:
            ref.grep_fields(field_rex, val_rex, prefix=prefix+'.')
        return None

    ###############################################################
    def ret_fields(self, pat=None, vpat=None):
        """
        ret_fields(selfm pat=None, vpat=None):
        search the entry for field names that match pat and field values
        that match vpat.
        Pats may be: strings w/regexps, compiled regexps, None
        If None --> match all (faster than matching .*)
        """
        if type(pat) == types.StringType:
            field_rex = re.compile(pat)
        else:
            field_rex = pat
        if type(vpat) == types.StringType:
            val_rex = re.compile(vpat)
        else:
            val_rex = vpat
        ret = {}
        for key in self.items.keys():
            if not field_rex or field_rex.search(key):
                if not val_rex or val_rex.search(self.items[key]):
                    ret[key] = self.items[key]

        for ref in self.references:
            t = ref.ret_fields(field_rex, val_rex)
            ret.update(t)
            
        return ret

    ###############################################################
    def print_fields(self, pat=None, vpat=None, prefix=''):
        """
        print_fields(selfm pat=None, vpat=None):
        search the entry for field names that match pat and field values
        that match vpat.
        Pats may be: strings w/regexps, compiled regexps, None
        If None --> match all (faster than matching .*)
        """
        if type(pat) == types.StringType:
            field_rex = re.compile(pat)
        else:
            field_rex = pat
        if type(vpat) == types.StringType:
            val_rex = re.compile(vpat)
        else:
            val_rex = vpat
        printed = 0
        for key in self.items.keys():
            if not field_rex or field_rex.search(key):
                if not val_rex or val_rex.search(self.items[key]):
                    print "%s%s: `%s\'" % (prefix, key, self.items[key])
                    printed = 1

        for ref in self.references:
            ref.print_fields(field_rex, val_rex, prefix=prefix+'ref:')

        if printed and prefix == '':
            print '--'

    def get_item(self, item, default=AttributeError):
        """get_item(self, item, default=AttributeError):
        Get the data item named in item.  default is the data to return
        if item is not present in the object.  If default is AttributeError,
        then raise an AttributeError if the item is not present."""
        places = (self,) + tuple(self.references)
        for place in places:
            try:
                return place.items[item]
            except KeyError:
                pass
        else:
            if default == AttributeError:
                raise default
            else:
                return default

    def dump(self):
        print 'items:', `self.items`

def prep():
    """prepare things so the python database works."""
    p = os.environ.get('PYDB_PATH')
    if not p:
        h = os.environ.get('HOME')
        if h:
            p = os.path.normpath(h + '/etc/pydb')
    if p:
        global pydb_dir
        pydb_dir = p
        if p not in sys.path:
            sys.path.insert(0, p)

def loadall(dirs=None, verbose=None):
    """load all databases in dirs."""

    if dirs == None:
        dirs = (pydb_dir,)
    elif type(dirs) == types.StringType:
        dirs = (dir,)

    pandb = PythonDataBase()
    for dir in dirs:
        if verbose:
            print 'loading dbs from:', dir
        for dbfile in os.listdir(dir):
            modname, modext = os.path.splitext(dbfile)
            if modext != '.py':
                continue
            if verbose:
                print 'name:', modname, 'ext:', modext
            if sys.modules.get(modname):
                continue
            if verbose:
                print 'exec import %s' % modname
            exec 'import %s' % modname
            
            pandb.join(sys.modules[modname].DB)

    return pandb
        
