#!/usr/bin/env python

import os, sys, string, re, getopt, types, StringIO
import pprint
import cPickle as pickle

import dp_io, dp_sequences, dp_utils
opath = os.path

ignore_file_not_found = 1
emacs_abbrev_table_name = 'dp-go-abbrev-table'
verbose = 0
debug = 0

ELISP_OUTPUT_HANDLER_FLAGS = "elisp output handler flags"
ELISP_EMIT_SETENV = "elisp output setenv"

GO_DICTIONARY_FILE = opath.join(os.environ["HOME"], "droppings")

PERMANENT_PREFIX = ""
PREFIX = ""
HOME = os.environ['HOME']
UGLY_HOME = dp_io.bq('cd $HOME; /bin/pwd')[:-1]
Shell_type = None                       # None means use $SHELL

SELECTOR_ENV = 'e'
SELECTOR_EMACS = 'E'
SELECTOR_EMACS_OR_ENV = SELECTOR_EMACS + "|" + SELECTOR_ENV
SELECTOR_PREFIX = 'p'
SELECTOR_PERMANENT_PREFIX = 'P'
SELECTOR_SIMPLE_LIST = 'l'
SELECTOR_NAMES_LIST = 'L'

DEFAULT_DICT_EXT = "_dict.py"
DEFAULT_SERIALIZED_FILE_NAME = "go"
DEFAULT_SERIALIZED_FILE = dp_utils.make_db_file_name(
    DEFAULT_SERIALIZED_FILE_NAME)
DEFAULT_DICT_FILE = DEFAULT_SERIALIZED_FILE + DEFAULT_DICT_EXT

KEEP_DICT_UPDATED = "KEEP_DICT_UPDATED"

MATCH_TYPE_LITERAL_DICT = "MATCH_TYPE_LITERAL_DICT"
MATCH_TYPE_LITERAL_ENV = "MATCH_TYPE_LITERAL_ENV"
MATCH_TYPE_REGEXP = "MATCH_TYPE_REGEXP"
MATCH_TYPE_REGEXP_LINE = "MATCH_TYPE_REGEXP_LINE"
MATCH_TYPE_ANY = "MATCH_TYPE_ANY"

# Use globals so we only need to get them once.

Global_aliases = {}

#####################################################################
def Set_aliases(aliases):
    global Global_aliases
    Global_aliases = aliases
    return aliases

def Get_aliases():
    return Global_aliases

Evil_globals = {}

class Val_in_kwargs(Exception):
    def __init__(self, s):
        self.d_s = s

    def __str__(self):
        return s

#
# Using a class allows us to differentiate types.
# Good for arrays, dicts or other collections of mixed types.
class Keyword_option_t(object):
    def __init__(self, name, val):
        self.d_name = name
        self.d_val = val
    def name(self):
        return self.d_name
    def val(self):
        return self.d_val
    def __str__(self):
        return "<Keyword_option_t, name: %s, val: %s>" % (self.name(),
                                                          self.val())
    def __repr__(self):
        return self.__str__()

def keep_dict_updated():
    return Evil_globals.get(KEEP_DICT_UPDATED, True)

#
# aliases[name] = (val,
#                 {"line": line, "selector": selector,
#                  "ctl": ctl, "aliases": aliases,
#                  "src_file_name": file_name})
#
#
## class Alias_item_t(object):
##     def __init__(self, val, **kw_args):
##         if type(val) == Types.StringType:
##             self.d_val = val
##             keys = kw_args.keys()
##             for k in ("val", "regexp"):
##                 if k in keys:
##                     raise Alias_reserved_keyword('Cannot use "%s" as a key.' \
##                                                  % (k,))
##                 self.d_kw_args = kw_args
##                 self.d_kw_args['val'] = val
##         else:
##             self.d_val = val["val"]
##             self.d_kw_args = val
##             self.d_kw_args.update(kw_args)
                

##     def get(self, name, default=None):
##         return self.d_kw_args.get(name, default)

##     def set(self, name, val):
##         self.d_kw_args[name] = val

##     def __call__(self):
##         return self.d_kw_args

##     def __repr__(self):
##         return "Alias_item_t({})".format(
##             pprint.pformat(self.d_kw_args))
## #             stringify_argified_dict(self.d_kw_args))
                          
    
#dp_io.eprintf('HOME>%s<, UGLY_HOME>%s<', HOME, UGLY_HOME)

#####################################################################
def handle_env_var(fmt, name, open_quote,val, close_quote, **kw_args):
    flags = kw_args.get(ELISP_OUTPUT_HANDLER_FLAGS, None)
    emit_setenv_p = False
    if flags:
        emit_setenv_p = flags.val()
    if emit_setenv_p:
        print '(setenv "%s" %s%s%s)' % (name, open_quote, val, close_quote)
    else:
        print fmt  % (name, open_quote, val, close_quote, name)

#####################################################################
def handle_sh(name, alias_item, **kw_args):
    val = alias_item.get("val")
    #
    # There are two kinds of environment outputs:
    # 1. Shell
    # B. elisp setenv calls
    quote_char = kw_args.get("quote_char",
                             Evil_globals.get("quote_char", '"'))
    handle_env_var('%s=%s%s%s; export %s;',
                   name,
                   quote_char, val, quote_char,
                   **kw_args)

#####################################################################
def handle_csh(name, alias_item, **kw_args):
    val = alias_item.get("val")
    #
    # There are two kinds of environment outputs:
    # 1. Shell
    # B. elisp setenv calls
    # The format to handle_env_var needs to take 3 parameters.
    # We just suck the 3rd into a comment.
    handle_env_var('setenv %s "%s"; # %s\n', name, val, **kw_args)

#####################################################################
def emacs_pre(**kw_args):
    ostream = kw_args.get("ostream", sys.stdout)
##is defining better?     ostream.write('(setq '
##is defining better?                   + emacs_abbrev_table_name
##is defining better?                   + ' (make-abbrev-table))\n')
    ostream.write(
        "(define-abbrev-table '{} nil)\n".format(emacs_abbrev_table_name))

#####################################################################
def handle_emacs(name, alias_item, **kw_args):
    """Emacs won't look past non-alpha numeric when expanding aliases,
    so we nuke those chars here."""
    val = alias_item.get("val")
    name = re.sub('[^a-zA-Z0-9]', '', name)
    # print '(define-abbrev %s "%s" "\\"%s\\"" nil 1)' % \
    # (emacs_abbrev_table_name, name, val)
    ostream = kw_args.get("ostream", sys.stdout)
    ostream.write('(define-abbrev %s "%s" "%s" nil 1)\n' \
                  % (emacs_abbrev_table_name, name, val))

#####################################################################
#
def handle_print(val, name, **kw_args):
    ostream = kw_args.get("ostream", sys.stdout)
    
##     ostream.write("{}    {}\n".format(first, second))
    if kw_args.get("grep-val"):
        ostream.write("{} -- {}\n".format(val, name))
    elif kw_args.get("grep-name"):
        ostream.write("{} -- {}\n".format(name, val))
    else:
        ostream.write("{}\n".format(first))

#####################################################################
#
def handle_grep_name(name, alias_item, **kw_args):
    val = alias_item.get("val")
    regexp = alias_item.get("regexp", ".*")
##     print >>sys.stderr, "name regexp>{}<, val>{}<".format(regexp,
##                                                           name)
    if re.search(regexp, name):
##         print >>sys.stderr, "name>%s<" % (name,)
##         print >>sys.stderr, "val>%s<" % (val,)
        handle_print(val, name, **kw_args)

#####################################################################
#
def handle_grep_val(name, alias_item, **kw_args):
    val = alias_item.get("val")
    regexp = alias_item.get("regexp", ".*")
##     print >>sys.stderr, "val regexp>{}<, val>{}<".format(regexp,
##                                                         val)
    if re.search(regexp, val):
##         print >>sys.stderr, "name>%s<" % (name,)
##         print >>sys.stderr, "val>%s<" % (val,)
        handle_print(val, name, **kw_args)

#####################################################################
#
# mapping from shell name to handler
# tuple:
# [0] = handler function
# [1] = prefix function, run once before anything is handled.
#       a good place to put initialization code.
# [2] = postfix function, run after all emissions are complete.
#       a good place for finalization
sh_handlers = (handle_sh, None, None)
csh_handlers = (handle_csh, None, None)
print_handlers = (handle_print, None, None)
grep_name_handlers = (handle_grep_name, None, None)
grep_val_handlers = (handle_grep_val, None, None)
shell_handlers = { 'bash': sh_handlers,
                   'sh': sh_handlers,
                   'ksh': sh_handlers,
                   'csh' : csh_handlers,
                   'tcsh': csh_handlers,
                   'print': print_handlers,
                   'grep': grep_name_handlers,
                   'grep-val': grep_val_handlers,
                   }
shell_handlers['bash2'] = shell_handlers['bash'] # same as bash
shell_handlers['grep_name'] = shell_handlers['grep']
shell_handlers['grep_val'] = shell_handlers['grep-val']

#####################################################################
def prefix_handler(name, val, **kw_args):
    """Set a prefix to add to all values."""
    global PREFIX
    PREFIX = val
    print >>sys.stderr, "PREFIX set to:", PREFIX

def permanent_prefix_handler(name, val, **kw_args):
    """Set a prefix to add to all values."""
    global PERMANENT_PREFIX
    PERMANENT_PREFIX = val
    print >>sys.stderr, "PERMANENT_PREFIX set to:", PERMANENT_PREFIX


#####################################################################
def environment_var_handler(shell):
    """Figure out what shell we are using so we can select
    the proper environment setting handler."""
    if not shell:
        shell = os.environ.get('SHELL', 'sh')
    shell_name = os.path.basename(shell)
    try:
        return shell_handlers[shell_name]
    except:
        dp_io.eprintf('*** Unknown shell>%s<\n',  shell)
        (None, None, None)

#####################################################################
def list_handler(name, alias_item, **kw_args):
    """Simple listing to stdout."""
    val = alias_item.get("val")
    ctl = alias_item.get("ctl")
    file_name = alias_item.get("src_file_name")
    print val, name, file_name, ctl

#def handle_sh(name, alias_item, **kw_args):
#Alias_item_t(val, line=line, selector=selector, ctl=ctl, file_name=file_name)

def LIST_handler(name, alias_item, **kw_args):
    val = alias_item.get("val")
    ctl = alias_item.get("ctl")
    file_name = alias_item.get("src_file_name")
    
    print "%s:%s" % (file_name,  val), name, file_name, ctl

#
# handlers map.
# key: selector char in .go file
# val: list of handlers for selector:
#   entry, prefix in file, suffix in file, selector-regexp
def get_handlers(shell_type=None):
    if shell_type == None:
        shell_type = Shell_type
    return { SELECTOR_EMACS:
             (
                 handle_emacs,
                 emacs_pre,
                 None,
                 SELECTOR_EMACS),
             SELECTOR_ENV:
             environment_var_handler(shell_type) + (SELECTOR_ENV,),
             SELECTOR_PREFIX:
             (
                 prefix_handler,
                 None,
                 None,
                 SELECTOR_PREFIX),
             SELECTOR_PERMANENT_PREFIX:
             (
                 permanent_prefix_handler,
                 None,
                 None,
                 SELECTOR_PERMANENT_PREFIX),
             SELECTOR_SIMPLE_LIST:
             (
                 list_handler,
                 None,
                 None,
                 SELECTOR_EMACS_OR_ENV),
             SELECTOR_NAMES_LIST:
             (
                 LIST_handler,
                 None,
                 None,
                 SELECTOR_EMACS_OR_ENV),
             }


#####################################################################
def expand_alias(line, selector, aliases, file_name):
    """Expand an alias line."""
    #(l, val) = string.split(line)
    # format: abc|a1|a2|<ws+>value
    m = re.search("(\S+)\s+(.+)$", line)
    dp_io.dprintf("""expand_alias: line>%s<
selector>%s<
aliases>%s<""", line, selector, aliases)
    if m:
        dp_io.debug("m.groups()>%s<\n", m.groups())

    if not m:
        if line[-1] == "\n":
            line = line[:-1]
        dp_io.eprintf("input line has bad format\n>%s<\n", line)
        return

    # format of the first part of a line:
    # ctl|alias0[|alias1...]\s+<expansion>
    # ctl says what kind of alias this is, e.g. emacs or environment
    l = m.group(1)
    val = m.group(2)
    var_name = val
    ##print >> sys.stderr, "l>%s<" % (l,)
    l = string.split(l, '|')
    ##print >> sys.stderr, "split l>%s<" % (l,)
    ctl = l[0]
    if re.search(selector, ctl):
        # get list of all aliases
        names = l[1:-1]
        val = os.path.expandvars(string.strip(val))
        #        print "l>%s<, names>%s<, selector>%s<, ctl>%s<" % (l, names, selector, ctl)

        # Remember if we were terminated by a '/' since this is done
        # on purpose to make entering dir names easier.
        if not val:
            dp_io.eprintf("Referencing empty or unset variable: `%s'\n",
                          var_name)
        else:
            last = val[-1]
            if last != '/':
                last = ''
            # Clean up value and terminate with a '/' if one was present
            # before.  This makes it more convient to use in emacs.
            val = os.path.normpath(val) + last
            val = re.sub('^'+UGLY_HOME, HOME, val)
            # Make URLs work.
            for proto in ("file", "https?", "ftp"):
                oldv = val
                val = re.sub("^(%s:/+)" % proto, "%s:///" % proto, val)
                if val != oldv:
                    # We found one and there should only be one.
                    break
            val = PREFIX + val
            for name in names:
                # add an entry for each alias. add to our list of
                # aliases.
                # also add to the environment so that references
                # in later entries get expanded properly
                os.environ[name] = val
                aliases[name] = {"val": val,
                                 "selector": selector,
                                 "ctl": ctl,
                                 "src_file_name": file_name}

#####################################################################
def expand_file(file, selector, aliases):
    """Expand all aliases in a given file."""
    #print >>sys.stderr, "Processing file:", file, ", selector:", selector
    try:
        f = open(file)
    except IOError, e:
        if ignore_file_not_found:
            return
        else:
            dp_io.eprintf('Cannot open %s, %s\n', file, e)
            return
    except Exception, e:
        dp_io.eprintf('Cannot open %s, %s\n', file, e)
        return
    global PREFIX
    PREFIX = PERMANENT_PREFIX
    lines = f.readlines()
    for line in lines:
        dp_io.dprintf('!!file: %s, line>%s<\n', file, line[:-1])
        # Comment line?  ; # and (for now only at BOL) //
        if re.search("^\s*(//|[;#])", line):
            continue
        if line == '\n':
            continue
        if re.search("^\s*$", line):
            # Catches "", too
            continue

        expand_alias(line, selector, aliases, file)


#####################################################################
def dump_dict(dict, name='dict', ostream=sys.stdout):
    print >>ostream, name, "= {"
    keys = dict.keys()
    keys.sort()
    for k in keys:
        v = dict[k]
        print >>ostream, "    '{}': {}".format(k, v)
    print >>ostream, "}"

#####################################################################
def stringify_dict(dict, name="dict"):
    output = StringIO.StringIO()
    dump_dict(dict, ostream=output)
    return output.getvalue().strip()

#####################################################################
def argify_dict(dict, ostream=sys.stdout):
    keys = dict.keys()
    keys.sort()
    sep = ''
    for k in keys:
        v = dict[k]
        print >>ostream, "{}{} = '{}'".format(sep, k, v),
        sep = ', '

#####################################################################
def stringify_argified_dict(dict):
    output = StringIO.StringIO()
    argify_dict(dict, ostream=output)
    return output.getvalue().strip()


#####################################################################
def expand_files(files, selector):
    """Expand a list of files."""
    aliases = {}
    for file in files:
        expand_file(file, selector, aliases)
    return aliases

#####################################################################
def init_aliases(args, selector_regexp,
                 serialized_file=DEFAULT_SERIALIZED_FILE,
                 dict_file=None):
    #
    # find the go path
    # The gopath looks like this:
    # /udir/davep/.go.ping:/udir/davep/.go.crl:/udir/davep/.go
    # most specific to least.  This is good when searching the gopath
    # directly.  For generating variables, we reverse the list so that
    # more specific files can override less specific ones.
    # dogo stops at the first match, and this produces the same effect.
    #
    if Get_aliases():
        return

    go_files, _ = dp_utils.process_gopath(args)

    if dict_file is not False:
        if not dict_file:
            dict_file = DEFAULT_DICT_FILE
        if keep_dict_updated():
##             print >>sys.stderr, "updating? dict."
            newest, _, _ = dp_utils.newest_file(go_files + [dict_file])
##             print >>sys.stderr, "newest>{}<".format(newest)
            if newest != dict_file:
##                 print >>sys.stderr, "writing dict."
                write_dict(args, dict_file)
        try:
            Set_aliases(read_dict(dict_file))
            if Get_aliases():
                return
        except Exception, err:
            print >>sys.stderr, "Exception `{}' reading dict file>{}<, trying pickle".format(err, dict_file)

    if serialized_file is not False:
        if not serialized_file:
            serialized_file = DEFAULT_SERIALIZED_FILE
        try:
            Set_aliases(read_aliases(serialized_file))
            return
        except Exception, err:
            print >>sys.stderr, "Exception `{}' reading pickle>{}<, falling back to .go file(s)".format(err, dict_file)

    Set_aliases(expand_files(go_files, selector_regexp))
##     print >>sys.stderr, "expanded files."

#####################################################################
def serialize_aliases(args, serialized_file=DEFAULT_SERIALIZED_FILE):
    init_aliases(args, ".*", False)
    if serialized_file is None:
        alias_pickle = pickle.dumps(Get_aliases())
        print >>sys.stderr, 'alias_pickle: {}'.format(alias_pickle)
    else:
        fobj = open(serialized_file, "w")
        pickle.dump(Get_aliases(), fobj)
        fobj.close()

#####################################################################
def read_aliases(serialized_file=DEFAULT_SERIALIZED_FILE):
    fobj = open(serialized_file, "r")
    ret = pickle.load(fobj)
    fobj.close()
    return ret

#####################################################################
def write_dict(args, dict_file=None):
    if not dict_file:
        return
    dname, fname = opath.split(dict_file)
    if not opath.exists(dict_file):
        dp_utils.mkpath(dname)
    init_aliases(args, ".*", False, False)
    fobj = open(dict_file, "w")
    beauty = pprint.pformat(Get_aliases(), indent=4, width=80, depth=None)
    fobj.write("aliases = ")
    fobj.write(beauty)
    fobj.write("\n")
    fobj.close()

#####################################################################
def read_dict(dict_file=None):
    import imp
    if not dict_file:
        dict_file = DEFAULT_DICT_FILE
    if not opath.exists(dict_file):
        return []
    dict_path = [opath.dirname(dict_file)]
    dict_name = opath.basename(opath.splitext(dict_file)[0])
    fobj, p, d = imp.find_module(dict_name, dict_path)
    z = imp.load_module("alias_file_aliases", fobj, p, d)
    fobj.close()
    return z.aliases

#####################################################################
def process_aliases(handle, handler_keyword_args,
                    handle_pre, handle_post,
                    aliases=Get_aliases(),
                    grep_regexps=None, ostream=sys.stdout):
    handler_keyword_args["ostream"] = ostream
    if handle_pre:
        handle_pre(**handler_keyword_args)
    if not grep_regexps:
        grep_regexps = (".*",)
    keys = aliases.keys()
    keys.sort()
    for regexp in grep_regexps:
        for k in keys:
            kw_args = handler_keyword_args
            aliases[k]["regexp"] = regexp
            #print >>sys.stderr, "kw_args:", kw_args
            handle(k, aliases[k], **kw_args)

    if handle_post:
        handle_post(aliases, keys)

#####################################################################
def go2env(args, handlers_type, selector, handler_keyword_args,
           grep_regexps, serialized_file=DEFAULT_SERIALIZED_FILE,
           ostream=sys.stdout):
    """Simple entry-point tailored to command line interface."""

#    print "args>%s<, handlers_type>%s<, selector>%s<, handler_keyword_args>%s<, grep_regexps>%s<" \
#          % (args, handlers_type, selector, handler_keyword_args,
#             grep_regexps)
    handlers = get_handlers(handlers_type)
    handle, handle_pre, handle_post, selector_regexp = handlers[selector]
    if type(selector_regexp) == types.StringType:
        selector_regexp = selector_regexp
        #print >>sys.stderr, "handle>%s<" % handle

    init_aliases(args=args, selector_regexp=selector_regexp,
                 serialized_file=serialized_file)
    ##!<@todo Stash away file name for better location purposes.
##     print "handle>%s<handle, aliases>%s<aliases, handler_keyword_args>%s<handler_keyword_args, handle_pre>%s<handle_pre, handle_post>%s<handle_post, grep_regexps>%s<grep_regexps, ostream>%s<ostream" \
##           % (handle, "SKIPPING" or aliases, handler_keyword_args, handle_pre, handle_post,
##              grep_regexps, ostream)

    process_aliases(handle=handle, aliases=Get_aliases(),
                    handler_keyword_args=handler_keyword_args,
                    handle_pre=handle_pre, handle_post=handle_post,
                    grep_regexps=grep_regexps,
                    ostream=ostream)

####################################################################
def simple_lookup(abbrev_regexp, try_environment_p=True,
                  selector=SELECTOR_ENV,
                  match_type=MATCH_TYPE_ANY,
                  serialized_file=DEFAULT_SERIALIZED_FILE):
    # Regexps with metacharacters probably won't be found.
    ## @todo XXX Make an environment grep?

    init_aliases(args=[], selector_regexp=".*")
    if match_type in (MATCH_TYPE_LITERAL_DICT, MATCH_TYPE_ANY):
        ret = Get_aliases().get(abbrev_regexp)
        if ret:
##             print >>sys.stderr, "hit"
            return ret["val"]
        elif not MATCH_TYPE_ANY:
            return None
##
## Using the environment should be a clear win, but oddly it turns out to
## usually be slower.
## The environment is also the most likely to be out of date.
## So, let's skip it.
        
##     if match_type in (MATCH_TYPE_LITERAL_ENV, MATCH_TYPE_ANY):
##         v = os.environ.get(abbrev_regexp)
##         if v:
##             # Make sure this is fully expanded. Ordering problems can leave
##             # unexpanded variables in values.
##             print >>sys.stderr, "ENV>{}<".format(abbrev_regexp)
##             return v
##         elif not MATCH_TYPE_ANY:
##             return None

    if match_type in (MATCH_TYPE_REGEXP_LINE, MATCH_TYPE_ANY):
        abbrev_regexp = "^" + abbrev_regexp + "$"
    output = StringIO.StringIO()
    go2env(args=[], handlers_type="grep", selector=selector,
           handler_keyword_args={},
           grep_regexps=(abbrev_regexp,),
           serialized_file=serialized_file,
           ostream=output)
    return output.getvalue().strip()

##needed? def simple_env_lookup(abbrev_regexp, try_environment_p=True,
##needed?                       line_match_p=False):
##needed?     return simple_lookup(abbrev_regexp=abbrev_regexp,
##needed?                          try_environment_p=try_environment_p,
##needed?                          line_match_p=line_match_p,
##needed?                          selector=SELECTOR_ENV)
               
#####################################################################
#####################################################################
if __name__ == "__main__":
    #
    # parse args
    #
    suffix = ""
    selector = SELECTOR_ENV
    grep_regexps = []
    opts, args = getopt.getopt(sys.argv[1:], 'efvdlLs:Eq:g:G:m:M:S:pP:a')
    handler_keyword_args = {}
    serialize_aliases_p = False
    serialized_file_name = DEFAULT_SERIALIZED_FILE_NAME
    write_dict_p = False
    for opt, val in opts:
        if opt == '-e':
            selector = SELECTOR_EMACS
        elif opt == '-f':               # make file not found fatal
            ignore_file_not_found = 0
        elif opt == '-v':
            verbose += 1
        elif opt == '-d':
            debug += 1
            dp_io.debug_on()
        elif opt == "-l":               # Simple listing
            selector = SELECTOR_SIMPLE_LIST
        elif opt == "-L":          # Simple listing with file names displayed
            selector = SELECTOR_NAMES_LIST
        elif opt == '-s':
            Shell_type = val            # Override $SHELL.
        elif opt == '-E':
            # Env is default, so this is rarely used.
            selector = SELECTOR_ENV
            handler_keyword_args[ELISP_OUTPUT_HANDLER_FLAGS] = \
               Keyword_option_t(ELISP_EMIT_SETENV, True)
        elif opt == '-q':
            Evil_globals["quote_char"] = val
        elif opt == '-g':
            grep_regexps.append(val)
            handler_keyword_args["grep-name"] = True
            Shell_type = "grep"
        elif opt == '-G':
            grep_regexps.append(val)
            handler_keyword_args["grep-val"] = True
            Shell_type = "grep-val"
        elif opt == '-S':
            suffix = val
        elif opt == '-M':
            # @todo XXX Do this with a front end since it is nvidia ME
            # specific.
            grep_regexps.append("^" + val + "__SB_rel$")
            Shell_type = "grep"
        elif opt == '-m':
            grep_regexps.append("^" + val + suffix + "$")
            Shell_type = "grep"
        elif opt == '-p':
            serialize_aliases_p = True
        elif opt == '-P':
            serialize_aliases_p = True
            serialized_file_name = v
        elif opt == '-a':
            write_dict_p = True

    serialized_file = opath.join(os.environ["HOME"], "var", "db",
                                 serialized_file_name)
    dict_file = serialized_file + DEFAULT_DICT_EXT

    if serialize_aliases_p:
        serialize_aliases(args, serialized_file)
        sys.exit(0)
    if write_dict_p:
        write_dict(args, dict_file)
        sys.exit(0)

    go2env(args=args, handlers_type=Shell_type, selector=selector,
           handler_keyword_args=handler_keyword_args,
           serialized_file=serialized_file,
           grep_regexps=grep_regexps)

