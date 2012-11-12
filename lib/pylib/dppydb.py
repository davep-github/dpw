"""pydb.py -- Python DataBase
A simple database built around python dictionaries.
A database entry is a dictionary indexed by field name.
Entries are searchable by field name or by field contents or both.

Databases are collections of entries.
Databases entries may be keyed.  The key is not necessary.
We can always search the db by brute force."""

#
# FE: look into multiple key hashes.
# ??? For get by key, try key in all dictionaries?
# ??? How to name ??? k1, k2, etc ???
#

import string, re, types, os, sys, fnmatch, dp_sequences, dp_io

dp_io.debug_on()
pydb_dir=''

###############################################################
class field_fixes:
    ###############################################################
    def __init__(self, ofile=None):
        if ofile == None:
            ofile = sys.stdout
        if ofile.isatty():
            self.field_pre = dp_io.BOLD or ''
            self.field_post = (dp_io.NORM or ':') + ' '
            self.value_pre = "`"
            self.value_post = "'"
        else:
            self.field_pre = ''
            self.field_post = ': '
            self.value_pre = "`"
            self.value_post = "'"

fixes = field_fixes()
    
#
# format a family name as a node name
# make it unlikey, inconvenient and illegal for a real node name
#
def family_to_node_name(fam):
    return ' ...*FAM:%s!`` ' % fam

def default_to_node_name():
    return ' ...default... '

def def_formatter(prefix, field, value, fixes=fixes):
    # this is almost 2x faster than string.join !
    return "%s%s%s%s%s%s%s" % (fixes.field_pre, prefix,
                               field, fixes.field_post,
                               fixes.value_pre, value, fixes.value_post)

###############################################################
class PythonDataBase:
    ###############################################################
    def __init__(self, entries=[], id='unspecified'):
        self.entries = []
        self.entries.extend(entries)
        self.keys = {}
        self.id = id

    ###############################################################
    def __getitem__(self, key):
        """__getitem__(self, key):
        If key is an INT, then use that as an index into the entries list.
         This helps in cases where we are iterating thru the entire list.
         We can use a for loop on the db item and so get one item at a time.
         This way, we don't have to build up and return a list of all items.
         To have an int as key, you'll need to `` into a string.
        Otherwise, use key as a key into keys."""
        
        if type(key) == types.IntType:
            return self.entries[key]
        elif self.keys != {}:
            return self.keys[key]
        else:
            raise 'Key search on unkeyed database.'

    ###############################################################
    def get(self, key, default=None):
        try:
            return self.keys[key]
        except KeyError:
            return default

    ###############################################################
    def dump(self, title=''):
        print 'dumping db(%s): %s\nvvvvvvvvvvvvvvvvvvvvvvvvvv' % (self, title)
        for e in self.entries:
            print 'e:', e
            e.dump()
        print '^^^^^^^^^^^^^^^^^^^^^^^^^^'
            
    ###############################################################
    def entries_as_list(self):
        return self.entries

    ###############################################################
    def grep_fields(self, pat=None, vpat=None):
        if type(pat) == types.StringType:
            rex = re.compile(pat)
        else:
            rex = pat
        if type(vpat) == types.StringType:
            val_rex = re.compile(vpat)
        else:
            val_rex = vpat
        ret = []
        for rec in self.entries_as_list():
            r = rec.grep_fields(rex, val_rex)
            if r:
                ret.append(r)
        return ret

    ###############################################################
    def join(self, new_db):
        self.entries.extend(new_db.entries)
        self.keys.update(new_db.keys)

    ###############################################################
    def add(self, key=None, dat=None, ref=None, kef=None):
        """add(self, key=None, dat=None, ref=None, kef=None):
        Add an entry to this database.  The args are funky.
        Since I want it to be easy to add just an entry, but I want
        to always use the keyword key= when a key is used, I do
        some extra twiddling of the args.
        So, add(x) adds a new entry, and assumes x is the dictionary
        of fields that make up the entry.  In all other cases,
        the args are processed normally.  I prefer to use keyword args
        in all cases except add(x)."""
        
        if dat == None:
            if type(key) != types.DictType:
                raise 'Single arg must be a dictionary'
            dat = key
            key = None

        entry = Entry(dat)
        if ref:
            # this node references other nodes
            entry.add_refs(ref)
        if kef != None:
            # The key is a field in the new entry.  get it by name,
            # using the value of the key.  This overrides a key if
            # one is passed in.
            # we want an error if it is not there
            if key != None:
                dp_io.eprintf('key >%s< is being overridden by kef.\n',
                              key)
            key=entry.get_item(kef, exception=KeyError)
        if key != None:
            self.keys[key] = entry
        self.entries.append(entry)
        return entry

###############################################################
class Entry:
    """class Entry
    A general purpose container for flexibly structured small data bases."""
    
    def __init__(self, *pargs, **kargs):
        """__init__(self, *list, **fields):
        Add all positional parameters in *pargs to the object's
        fields element. Each element of *pargs must be a dictionary.
        Add all the key/val pairs in **kargs to the object's
        fields element."""
        
        self.references = []
        self.fields = {}
        apply(self.add_fields, pargs)
        self.add_fields(kargs)
        self.all_my_refs = []
        # print 'self.fields>%s<' % self.fields

    ###############################################################
    def add_refs(self, refs):
        if dp_sequences.is_listlike(refs):
            self.references.extend(refs)
        else:
            self.references.append(refs)
        
    ###############################################################
    def add_fields(self, *pargs, **kargs):
        """add_fields(self, *pargs, **kargs):
        Each element of pargs must be a dictionary.
        kargs is all of the keyword/val pairs collected into a dictionary.
        kargs is nice for adding a bunch of fields explicitly, although
        an initialized dictionary as a parg is more flexible with
        respect to naming keys.  As a karg, each key must be a legit
        python identifier.  As a dictionary in a parg, any hashable
        entity can be the key."""

        if pargs:
            l = pargs
        else:
            l = ()
        if kargs:
            l = l + (kargs,)

        for d in l:
            for k in d.keys():
                for k2 in string.split(k, '|'):
                    self.fields[k2] = d[k2]

    ###############################################################
    def grep_fields(self, pat=None, vpat=None):
        """grep_fields(self, pat=None, vpat=None):
        search the entry for field names that match pat and field values
        that match vpat.
        Pats may be: strings w/regexps, compiled regexps, None
        If None --> match all (faster than matching .*)
        Return the entry if anything matches.
        Also search the referenced entries"""
        
        if type(pat) == types.StringType:
            field_rex = re.compile(pat)
        else:
            field_rex = pat
        if type(vpat) == types.StringType:
            val_rex = re.compile(vpat)
        else:
            val_rex = vpat
        #
        # search the item for a match.
        #
        # print '+++++++++++++++++++++++++++'
        # print 'keys:', self.fields.keys()
        for key in self.fields.keys():
            if not field_rex or field_rex.search(key):
                try:
                    # print 'f>%s< or v>%s<' % (key, self.fields[key])
                    if not val_rex or val_rex.search(self.fields[key]):
                        return self
                except TypeError:
                    print '*******keys:', self.fields.keys()
                    #print 'Not a string: f>%s< or v>%s<' % (key, self.fields[key])
                    continue

        for ref in self.references:
            # print 'looking at ref:', ref
            if ref.grep_fields(field_rex, val_rex):
                return self
        return None

    ###############################################################
    def get_all_refs(self):
        """get_all_refs(self)
        return a list of all references in the same order that
        grep_fields() would visit them."""

        if self.all_my_refs:
            return self.all_my_refs
            
        refs = []
        for ref in self.references:
            refs.append(ref)
            refs.extend(ref.get_all_refs())
        self.all_my_refs = refs
        return refs

    ###############################################################
    def ret_fields(self, pat=None, vpat=None):
        """ret_fields(selfm pat=None, vpat=None):
        search the entry for field names that match pat
        and field values that match vpat.
        Pats may be: strings w/regexps, compiled regexps, None
        If None --> match all (hopefully faster than matching .*)"""
        
        if type(pat) == types.StringType:
            field_rex = re.compile(pat)
        else:
            field_rex = pat
        if type(vpat) == types.StringType:
            val_rex = re.compile(vpat)
        else:
            val_rex = vpat

        ret = {}
        entries = (self, ) + tuple(self.get_all_refs())

        for entry in entries:
            #print 'entry, field keys>%s<' % entry.fields.keys()
            for key in entry.fields.keys():
                if not field_rex or field_rex.search(key):
                    if not val_rex or val_rex.search(entry.fields[key]):
                        #
                        # do not overwrite any existing value.
                        # this allows us to override fields since
                        # we scan "top down"
                        #
                        if not ret.has_key(key):
                            ret[key] = entry.fields[key]

        #print 'ret, keys>%s<' % ret.keys()
        return ret

    ###############################################################
    def print_fields(self, pat=None, vpat=None, sortem=None,
                     formatter = def_formatter,
                     print_sep='--'):
        """print_fields(selfm pat=None, vpat=None):
        call ret_fields to get fields that match.
        The optionally sort by field name and print as
        formatted by formatter."""

        fields = self.ret_fields(pat, vpat)
        keys = fields.keys()
        if sortem:
            keys.sort()
        for field in keys:
            #print 'field>%s<' % field
            print formatter('', field, fields[field])

        if fields:
            print print_sep

    ###############################################################
    def get_item(self, field, default=None, exception=None):
        """get_item(self, field, default=AttributeError):
        Get the data item named in field.   Search the
        object first, then all references in order.
        If item is not present in the object:
           if exception is not None then raise exception
           otherwise return default."""

        try:
            return self.fields[field]
        except KeyError:
            pass
        for place in self.references:
            try:
                return place.get_item(field, exception=KeyError)
            except KeyError:
                pass
        else:
            if exception != None:
                raise exception
            else:
                return default

    ###############################################################
    def __getitem__(self, key):
        """Implement the index operation, e.g. entry[key]"""
        return self.get_item(key, exception=KeyError)

    ###############################################################
    def dump(self):
        print 'fields:', `self.fields`



###############################################################
def prep(db_location=None):
    """prepare things so the python database works."""
    
    p = db_location
    if not p:
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
    else:
        dp_io.eprintf("""Cannot determine database location.
 Try passing in a dir to db.prep().\n""")
        raise RuntimeError("Cannot determine database location.")

###############################################################
def get_db_dirs(dirs=None):
    if not dirs:
        ret = (pydb_dir,)
    else:
        ret = dp_sequences.mklist(dirs)
    return ret

###############################################################
def cleanup_locale(s):
    if s:
        s = s + '.'
    return s
    
###############################################################
def mk_loclist(localize=None, loclist=None):
    """make a localization list.
    If loclist is given, return that + an empty locale for
    non-localize files.
    Otherwise, if localize is set, convert the envvar locale_rcs
    into a locale list."""
    if loclist == None:
        if localize:
            loclist = string.split(os.getenv('locale_rcs', ''))
            loclist = map(lambda s: s[1:], loclist)
        else:
            loclist = []
    loclist.append('')                  # '' will result in unlocalized name
    loclist = map(cleanup_locale, loclist)
    #print 'loclist>%s<' % string.join(loclist, '<, >')
    return loclist

###############################################################
def find_db_file(dbfile, localize=None, loclist=None):
    """Find a db file.  If localize is set, use the contents of
    the locale_rcs envvar to find a more specific version
    Use loclist if set"""
    ret = []
    loclist = mk_loclist(localize, loclist)
    dirs = get_db_dirs(None)
    for dir in dirs:
        for file in os.listdir(dir):
            # try for localized versions in order
            for loc in loclist:
                tfile = loc + file
                #print 'tfile>%s<' % tfile
                modname, modext = os.path.splitext(tfile)
                if modext != '.py':
                    continue
            
                if fnmatch.fnmatch(modname, dbfile):
                    ret.append(os.path.normpath(dir+'/'+modname+'.py'))
                else:
                    continue
    #print 'returning>%s<' % string.join(ret, ', ')
    return ret

###############################################################
def load(dirs=None, pat=None, wild=None, verbose=None, localize=None, loclist=None):
    """load(dirs=None, pat=None, wild=None, verbose=None):
    Within the directories in dirs,
    load all databases matching pat (a python regular expression)
    or matching shell type wildcards in wild.
    You cannot specify both pat and wild."""

    if verbose:
        print 'wild>%s<, pat>%s<, dirs>%s<' % (wild, pat, dirs)

    dirs = get_db_dirs(dirs)

    if verbose:
        print 'wild>%s<, pat>%s<, dirs>%s<' % (wild, pat, dirs)

    if wild and pat:
        dp_io.eprintf("Cannot specify both pat and wild.\n")
        raise RuntimeError("Cannot specify both pat and wild")

    loclist = mk_loclist(localize, loclist)

    if not wild:
        if type(pat) == types.StringType:
            rex = re.compile(pat)
        else:
            rex = pat
        # distribute locales across rex w/| op
    else:
        wild = dp_sequences.mklist(wild)
        w2 = []
        for w in wild:
            for loc in loclist:
                w2.append(loc + w)
        wild = w2
        #print 'wild>%s<' % string.join(wild, '<, >')

    pandb = PythonDataBase()
    orig_syspath = sys.path
    try:
        for dir in dirs:
            # force current dir to front of path
            if verbose:
                print 'check >%s<' % dir
            sys.path = [dir]
            if verbose:
                print 'loading dbs from:', dir
            for dbfile in os.listdir(dir):
                modname, modext = os.path.splitext(dbfile)
                if modext != '.py':
                    continue

                process_file = 0
                if wild:
                    for w in wild:
                        if verbose:
                            print '**wild check, w:', w, 'modname:', modname
                        if fnmatch.fnmatch(modname, w):
                            process_file = 1
                            break
                        else:
                            continue
                else:
                    process_file = not rex or rex.search(modname)

                if not process_file:
                    continue

                if verbose:
                    print 'name:', modname, 'ext:', modext
                if sys.modules.get(modname):
                    # already loaded
                    continue
                if verbose:
                    print 'exec import %s' % modname
                exec 'import %s' % modname

                pandb.join(sys.modules[modname].DB)
    finally:
        sys.path = orig_syspath

    return pandb

###############################################################
def loadall(dirs=None, verbose=None):
    """loadall(dirs=None, verbose=None):
    load all databases in dirs"""
    
    return load(dirs, verbose=verbose)
