#!/usr/bin/env python

import os, sys, re, getopt, io, errno
import pprint
import pickle as pickle

debug_file = sys.stderr
verbose_file = sys.stderr
warning_file = sys.stderr

import dp_io, dp_utils
opath = os.path

ignore_file_not_found = 1
emacs_abbrev_table_name = 'dp-go-abbrev-table'
verbose = 0
debug = 0

ELISP_OUTPUT_HANDLER_FLAGS = "elisp output handler flags"
ELISP_EMIT_SETENV = "elisp output setenv"

PERMANENT_PREFIX = ""
PREFIX = ""
HOME = os.environ['HOME']
UGLY_HOME = dp_io.bq('cd $HOME; /bin/pwd', text=True)[:-1]
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

KEEP_DICT_UPDATED_P = "KEEP_DICT_UPDATED_P"
FORCE_DICT_UPDATED_P = "FORCE_DICT_UPDATED_P"

MATCH_TYPE_LITERAL_DICT = "MATCH_TYPE_LITERAL_DICT"
MATCH_TYPE_LITERAL_ENV = "MATCH_TYPE_LITERAL_ENV"
MATCH_TYPE_REGEXP = "MATCH_TYPE_REGEXP"
MATCH_TYPE_REGEXP_LINE = "MATCH_TYPE_REGEXP_LINE"
MATCH_TYPE_ANY = "MATCH_TYPE_ANY"

# Use globals so we only need to get them once.

Global_aliases = {}
Evil_globals = {}


#####################################################################
def Set_aliases(aliases):
    global Global_aliases
    Global_aliases = aliases
    return aliases


#####################################################################
def Get_aliases():
    return Global_aliases


#####################################################################
class Val_in_kwargs(Exception):
    def __init__(self, s):
        self.d_s = s

    def __str__(self):
        return self.d_s


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


#####################################################################
def keep_dict_updated_p():
    ret = Evil_globals.get(KEEP_DICT_UPDATED_P, True)
    # print >>sys.stderr, "keep_dict_updated_p:", ret
    return ret


#####################################################################
def set_keep_dict_updated_p(val=True):
    if val is None:
        val = not keep_dict_updated_p()
    Evil_globals[KEEP_DICT_UPDATED_P] = val
    return val


#####################################################################
def force_dict_updated_p():
    ret = Evil_globals.get(FORCE_DICT_UPDATED_P, False)
    # print >>sys.stderr, "force_dict_updated_p:", ret
    return ret


#####################################################################
def set_force_dict_updated_p(val=True):
    if val is None:
        val = not force_dict_updated_p()
    Evil_globals[FORCE_DICT_UPDATED_P] = val
    return val

#
# aliases[name] = (val,
#                 {"line": line, "selector": selector,
#                  "ctl": ctl, "aliases": aliases,
#                  "src_file_name": file_name})
#
#
# class Alias_item_t(object):
#     def __init__(self, val, **kw_args):
#         if type(val) == Types.StringType:
#             self.d_val = val
#             keys = kw_args.keys()
#             for k in ("val", "regexp"):
#                 if k in keys:
#                     raise Alias_reserved_keyword('Cannot use "%s" as a key.'
#                                                  % (k,))
#                 self.d_kw_args = kw_args
#                 self.d_kw_args['val'] = val
#         else:
#             self.d_val = val["val"]
#             self.d_kw_args = val
#             self.d_kw_args.update(kw_args)


#     def get(self, name, default=None):
#         return self.d_kw_args.get(name, default)

#     def set(self, name, val):
#         self.d_kw_args[name] = val

#     def __call__(self):
#         return self.d_kw_args

#     def __repr__(self):
#         return "Alias_item_t({})".format(
#             pprint.pformat(self.d_kw_args))
# #             stringify_argified_dict(self.d_kw_args))


#####################################################################
def handle_env_var(fmt, name, open_quote, val, close_quote,
                   **kw_args):
    flags = kw_args.get(ELISP_OUTPUT_HANDLER_FLAGS, None)

    # @todo XXX unused
    emit_setenv_p = False
    if flags:
        emit_setenv_p = flags.val()
    if emit_setenv_p:
        print('(setenv "%s" %s%s%s)' % (name, open_quote, val, close_quote))
    else:
        print(fmt % (name, open_quote, val, close_quote, name))


#####################################################################
def handle_sh(name, alias_item, **kw_args):
    val = alias_item.get("val")
    #
    # There are two kinds of environment outputs:
    # 1. Shell
    # B. elisp setenv calls
    quote_char = kw_args.get("quote_char",
                             Evil_globals.get("quote_char", '"'))

    unset_var_p = kw_args.get("unset_var_p", False)
    unset_var_first_p = kw_args.get("unset_var_first_p", False)
    if unset_var_p or unset_var_first_p:
        fmt = "unset %s\n"
        dp_io.printf("unset %s\n", name)
    if not unset_var_p:
        fmt = '%s=%s%s%s; export %s;'
        handle_env_var(
            fmt=fmt,
            name=name,
            open_quote=quote_char,
            val=val,
            close_quote=quote_char,
            **kw_args)


#####################################################################
def handle_csh(name, alias_item, **kw_args):
    val = alias_item.get("val")
    #
    # There are two kinds of environment outputs:
    # 1. Shell
    # B. elisp setenv calls
    # The format to handle_env_var needs to take 3 parameters.
    # We just stuff the 3rd into a comment.
    # @todo XXX ??? This won't work.  Deal with it if I ever go t?csh.
    quote_char = kw_args.get("quote_char",
                             Evil_globals.get("quote_char", '"'))
    handle_env_var(
        fmt='setenv %s %s%s%s; # %s',
        name=name,
        open_quote=quote_char,
        val=val,
        close_quote=quote_char,
        **kw_args)


#####################################################################
def emacs_pre(**kw_args):
    ostream = kw_args.get("ostream", sys.stdout)
# is defining better?     ostream.write('(setq '
# is defining better?                   + emacs_abbrev_table_name
# is defining better?                   + ' (make-abbrev-table))\n')
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
    ostream.write('(define-abbrev %s "%s" "%s" nil 1)\n'
                  % (emacs_abbrev_table_name, name, val))


#####################################################################
#
def handle_print(val, name, **kw_args):
    ostream = kw_args.get("ostream", sys.stdout)
    did_something = False

#     ostream.write("{}    {}\n".format(first, second))
    if kw_args.get("grep-val"):
        ostream.write("{} -- {}\n".format(val, name))
        did_something = True
    if kw_args.get("grep-name"):
        ostream.write("{} -- {}\n".format(name, val))
        did_something = True
    if kw_args.get("grep-name-only"):
        ostream.write("{}\n".format(name))
        did_something = True
    if kw_args.get("grep-val-only"):
        ostream.write("{}\n".format(val))

    if did_something is not True:
        ostream.write("{}\n".format(val))


#####################################################################
#
def handle_grep_name(name, alias_item, **kw_args):
    val = alias_item.get("val")
    regexp = alias_item.get("regexp", ".*")
    # print >>sys.stderr, "name regexp>{}<, val>{}<".format(regexp,
    #                                                       name)
    if re.search(regexp, name):
        # print >>sys.stderr, "name>%s<" % (name,)
        # print >>sys.stderr, "val>%s<" % (val,)
        handle_print(val, name, **kw_args)


#####################################################################
#
def handle_grep_val(name, alias_item, **kw_args):
    val = alias_item.get("val")
    regexp = alias_item.get("regexp", ".*")
    #     print >>sys.stderr, "val regexp>{}<, val>{}<".format(regexp,
    #                                                          val)
    if re.search(regexp, val):
        #         print >>sys.stderr, "name>%s<" % (name,)
        #         print >>sys.stderr, "val>%s<" % (val,)
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
shell_handlers = {
    'bash': sh_handlers,
    'zsh': sh_handlers,
    'sh': sh_handlers,
    'ksh': sh_handlers,
    'csh': csh_handlers,
    'tcsh': csh_handlers,
    'print': print_handlers,
    'grep': grep_name_handlers,
    'grep-val': grep_val_handlers,
}
shell_handlers['bash2'] = shell_handlers['bash']  # same as bash
shell_handlers['tcsh'] = shell_handlers['csh']  # same as csh
shell_handlers['grep_name'] = shell_handlers['grep']
shell_handlers['grep_val'] = shell_handlers['grep-val']


#####################################################################
def prefix_handler(name, val, **kw_args):
    """Set a prefix to add to all values."""
    global PREFIX
    PREFIX = val
    print("PREFIX set to:", PREFIX, file=sys.stderr)


#####################################################################
def permanent_prefix_handler(name, val, **kw_args):
    """Set a prefix to add to all values."""
    global PERMANENT_PREFIX
    PERMANENT_PREFIX = val
    print("PERMANENT_PREFIX set to:", PERMANENT_PREFIX, file=sys.stderr)


#####################################################################
def get_environment_var_handler(shell):
    """Figure out what shell we are using so we can select
    the proper environment setting handler."""
    b = os.environ.get("BASH", False)
    if b:
        os.environ["SHELL"] = b
    else:
        if os.environ.get("DP_BASHRC"):
            os.environ["SHELL"] = "bash"
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
    print(val, name, file_name, ctl)

#def handle_sh(name, alias_item, **kw_args):
#Alias_item_t(val, line=line, selector=selector, ctl=ctl, file_name=file_name)


#####################################################################
def LIST_handler(name, alias_item, **kw_args):
    val = alias_item.get("val")
    ctl = alias_item.get("ctl")
    file_name = alias_item.get("src_file_name")

    print("%s:%s" % (file_name,  val), name, file_name, ctl)


#####################################################################
#
# handlers map.
# key: selector char in .go file
# val: list of handlers for selector:
#   entry, prefix in file, suffix in file, selector-regexp
def get_handlers(shell_type=None):
    dp_io.cdebug(1, "get_handlers(): in: shell_type>{}<\n", shell_type)
    if shell_type is None:
        shell_type = Shell_type
    dp_io.cdebug(1, "get_handlers(): shell_type>{}<\n", shell_type)
    return {SELECTOR_EMACS:
            (
                handle_emacs,
                emacs_pre,
                None,
                SELECTOR_EMACS),
            SELECTOR_ENV:
            get_environment_var_handler(shell_type) + (SELECTOR_ENV,),
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
def expand_alias(line, selector, aliases, file_name, line_num):
    """Expand an alias line."""
    # (l, val) = str.split(line)
    # format: abc|a1|a2|<ws+>value
    m = re.search("(\S+)\s+(.+)$", line)
    dp_io.dprintf("""expand_alias: %d, line>%s<
selector>%s<
aliases>%s<\n""", line_num, line, selector, aliases)
    if m:
        dp_io.debug("m.groups()>%s<\n", m.groups())

    if not m:
        if line[-1] == "\n":
            line = line[:-1]
        if file_name:
            name_msg = "{}: ".format(file_name)
        else:
            name_msg = ""

        dp_io.eprintf("input line %s%d has bad format\n>%s<\n",
                      name_msg, line_num, line)
        return

    # format of the first part of a line:
    # ctl|alias0[|alias1...]\s+<expansion>
    # ctl says what kind of alias this is, e.g. emacs or environment
    l = m.group(1)
    val = m.group(2)
    var_name = val
    ##print >> sys.stderr, "l>%s<" % (l,)
    l = str.split(l, '|')
    # print >> sys.stderr, "split | result l>%s<" % (l,)
    ctl = l[0]
    m = re.search(selector, ctl)
    # print >> sys.stderr, "ctl>%s<, selector>%s<, m>%s<" % (ctl, selector, m)
    if m:
        # get list of all aliases
        names = l[1:-1]
        val = os.path.expandvars(str.strip(val))
        dp_io.debug("l>%s<, names>%s<, selector>%s<, ctl>%s<, val>%s<\n",
                    l, names, selector, ctl, val)

        # Remember if we were terminated by a '/' since this is done
        # on purpose to make entering dir names easier.
        if not val:
            dp_io.eprintf("""Referencing empty or unset variable: `%s'\n""",
                          var_name)
            dp_io.eprintf("""line>%s<\n""", line)
        else:
            last = val[-1]
            if last != '/':
                last = ''
            # Clean up value and terminate with a '/' if one was present
            # before.  A trailing / makes it more convient to use in emacs.
            # But we only preserve it, not add it.
            val = os.path.normpath(val) + last
            dp_io.dprintf("type(val): %s, val>%s<\n", type(val), val)
            dp_io.dprintf("type(HOME): %s, HOME>%s<\n", type(HOME), HOME)
            dp_io.dprintf("type(UGLY_HOME): %s, UGLY_HOME>%s<\n",
                          type(UGLY_HOME), UGLY_HOME)

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
                try:
                    os.environ[name] = val
                    aliases[name] = {"val": val,
                                     "selector": selector,
                                     "ctl": ctl,
                                     "src_file_name": file_name}
                except Exception as e:
                    dp_io.eprintf("Exception caught in %s(): %s\n",
                                  dp_utils.function_name(), e)
                    dp_io.eprintf("line>%s<\n", line)
                    dp_io.eprintf("name>%s<\n", name)
                    dp_io.eprintf("val>%s<\n", val)
                    dp_io.eprintf("Skipping...\n")
                    # Keep on keepin' on.
                    # @todo XXX Even after an error, we'll use the compiled
                    # dictionary which won't repeat the error and it may
                    # fall through the cracks.  Should either not save the
                    # compiled version or save an error log and print it
                    # when we run.


#####################################################################
def expand_file(file, selector, aliases):
    """Expand all aliases in a given file."""
    # print "# Processing file:", file, ", selector:", selector
    try:
        fobj = open(file)
    except IOError as e:
        if ignore_file_not_found:
            return
        else:
            dp_io.eprintf('Cannot open %s, %s\n', file, e)
            return
    except Exception as e:
        dp_io.eprintf('Cannot open %s, %s\n', file, e)
        return
    global PREFIX
    PREFIX = PERMANENT_PREFIX
    line_num = 0
    for line in fobj:
        line_num = line_num + 1
        dp_io.dprintf('!!file: %s, line>%s<\n', file, line[:-1])
        # Comment line?  ; # and (for now only at BOL) //
        if re.search("^\s*(//|[;#])", line):
            continue
        if line == '\n':
            continue
        if re.search("^\s*$", line):
            # Catches "", too
            continue

        expand_alias(line, selector, aliases, file, line_num)
    fobj.close()


#####################################################################
def dump_dict(dict, name='dict', ostream=sys.stdout):
    print(name, "= {", file=ostream)
    keys = list(dict.keys())
    keys.sort()
    for k in keys:
        v = dict[k]
        print("    '{}': {}".format(k, v), file=ostream)
    print("}", file=ostream)


#####################################################################
def stringify_dict(dict, name="dict"):
    output = io.StringIO()
    dump_dict(dict, ostream=output)
    return output.getvalue().strip()


#####################################################################
def argify_dict(dict, ostream=sys.stdout):
    keys = list(dict.keys())
    keys.sort()
    sep = ''
    for k in keys:
        v = dict[k]
        print("{}{} = '{}'".format(sep, k, v), end=' ', file=ostream)
        sep = ', '


#####################################################################
def stringify_argified_dict(dict):
    output = io.StringIO()
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
                 dict_file=None,
                 force_update_p=False):
    #
    # find the go path
    # The gopath looks like this:
    # /udir/davep/.go.ping:/udir/davep/.go.crl:/udir/davep/.go
    # most specific to least.  This is good when searching the gopath
    # directly.  For generating variables, we reverse the list so that
    # more specific files can override less specific ones.
    # dogo stops at the first match, and this produces the same effect.
    #

    #    if selector_regexp == '.*':
    #        dp_io.debug("init_aliases(): selector_regexp is >{}<\n", selector_regexp)

    if Get_aliases():
        return

    go_files, _ = dp_utils.process_gopath(args)

    keep_looping = 2
    while keep_looping:
        # print >>debug_file, "keep_looping:", keep_looping
        keep_looping = keep_looping - 1
        # Try to read the compiled dict file (e.g. go_dict.pyc)
        if dict_file is not False:
            if not dict_file:
                dict_file = DEFAULT_DICT_FILE
            if (keep_dict_updated_p()
                or force_update_p
                or force_dict_updated_p()):
                # print >>sys.stderr, "updating? dict."
                newest, _, _ = dp_utils.newest_file(go_files + [dict_file])
                # print >>sys.stderr, "newest>{}<".format(newest)
                dp_io.cdebug(1, "newest>{}<\n", newest)

                if ((newest != dict_file)
                    or force_update_p
                    or force_dict_updated_p()):
                    # print >>sys.stderr, "writing dict."
                    write_dict(args, dict_file)
            try:
                Set_aliases(read_dict(dict_file))
                if Get_aliases():
                    return
            except AttributeError as err:
                # Sometimes the file is hosed.  Still trying to figure out why.
                # This doesn't really help.
                # Is it due to multiple shells starting at once?
                # This right, without looping BS?
                print("Exception `{}' reading dict file>{}<".format(err,
                                                                    dict_file),
                      file=sys.stderr)
                pyc_file = "%sc" % (dict_file,)
                print("pyc_file>%s<" % (pyc_file), file=sys.stderr)
                os.system("rm -f %s" % (pyc_file,))
                if keep_looping == 1:
                    break
                keep_looping = keep_looping - 1
                print("   removed file and retrying.", file=sys.stderr)
                continue
            except Exception as err:
                print("Exception `{}' reading dict file>{}<,"
                      " trying pickle".format(err, dict_file), file=sys.stderr)

        # Try for something pickled.
        if serialized_file is not False:
            if not serialized_file:
                serialized_file = DEFAULT_SERIALIZED_FILE
            try:
                Set_aliases(read_aliases(serialized_file))
                return
            except Exception as err:
                # try to write what we know.
                serialized_file = None
                if keep_looping == 1:
                    print("Exception `{}' reading pickle>{}<, falling back to .go file(s)".format(err, dict_file), file=sys.stderr)
                    keep_looping = 0
                else:
                    keep_looping = keep_looping - 1
                    force_update_p = True
        break

    # Slurp it out of the .go[.*] files.
    # It should be saved later.
    # print "# Expanding go files."
    Set_aliases(expand_files(go_files, selector_regexp))
    # print >>sys.stderr, "expanded files>%s<." %(go_files,)


#####################################################################
def serialize_aliases(args, serialized_file=DEFAULT_SERIALIZED_FILE):
    dp_io.cdebug(1, "in serialize_aliases()\n")
    init_aliases(args, ".*", False)
    if serialized_file is None:
        alias_pickle = pickle.dumps(Get_aliases())
        print('alias_pickle: {}'.format(alias_pickle), file=sys.stderr)
    else:
        fobj = open(serialized_file, "w")
        pickle.dump(Get_aliases(), fobj)
        fobj.close()


#####################################################################
def read_aliases(serialized_file=DEFAULT_SERIALIZED_FILE):
    dp_io.cdebug(1, "in read_aliases()\n")
    fobj = open(serialized_file, "r")
    ret = pickle.load(fobj)
    fobj.close()
    return ret


#####################################################################
def write_dict(args, dict_file=None):
    dp_io.cdebug(1, "in write_dict()\n")
    if not dict_file:
        return
    dname, fname = opath.split(dict_file)
    # print >>debug_file, "dict_file: {}, dname: {}, fname: {}".format(dict_file, dname, fname)
    if not opath.exists(dict_file):
        dp_utils.mkpath(dname)
    dp_io.cdebug(1, "in write_dict() calling init_aliases()\n")
    init_aliases(args, ".*", False, False)
    fobj = open(dict_file, "w")
    beauty = pprint.pformat(Get_aliases(), indent=4, width=80, depth=None)
    fobj.write("aliases = ")
    fobj.write(beauty)
    fobj.write("\n")
    fobj.close()


#####################################################################
# Newe version.
def read_dict(dict_file=None):
    dp_io.cdebug(1, "in read_dict(dict_file:%s)\n", dict_file)
    import importlib
    if not dict_file:
        dict_file = DEFAULT_DICT_FILE
    if not opath.exists(dict_file):
        return []
    # Being too stupid to find out how to do it the right way, he does it the
    # stupid way. Hi Algy, how ya doin'?
    # So, add the path part of the file name to sys.path, then remove it.
    dict_path = [opath.dirname(dict_file)]
    dict_path.extend(sys.path)
    sys.path = dict_path
    dict_name = opath.basename(opath.splitext(dict_file)[0])
    z = importlib.import_module(dict_name)
    sys.path = sys.path[1:]
    dp_io.dprintf("""read_dict(): sys_path>%s<\n""", sys.path)
    return z.aliases


#####################################################################
def valid_env_var_name(name):
    """This is a an embarrassing HACK to get around the fact that a bug crept
    in that causes everything to be exported."""
    dp_io.cdebug(2, "valid_env_var_name(): name>{}<\n", name)

    return name and name[0] not in "0123456789"


#####################################################################
def process_aliases(handle, handler_keyword_args,
                    handle_pre, handle_post,
                    aliases=Get_aliases(),
                    grep_regexps=None, ostream=sys.stdout):
    dp_io.cdebug(1, "in process_aliases(), handle: {}, handler_keyword_args: {}\n",
                 handle, handler_keyword_args)
    handler_keyword_args["ostream"] = ostream
    if handle_pre:
        handle_pre(**handler_keyword_args)
    if not grep_regexps:
        dp_io.cdebug(1, "in process_aliases() setting grep_regexps to .*\n")
        grep_regexps = (".*",)
    keys = list(aliases.keys())
    keys.sort()
    for regexp in grep_regexps:
        dp_io.cdebug(2, "process_aliases(): regexp>{}<\n", regexp)
        for k in keys:
            alias_item = aliases[k]
            dp_io.cdebug(2, "process_aliases(): k: {}, alias_item>{}<\n",
                         k, alias_item)
            if not valid_env_var_name(k):
                continue
            kw_args = handler_keyword_args
            aliases[k]["regexp"] = regexp
            # print >>sys.stderr, "kw_args:", kw_args
            handle(k, alias_item, **kw_args)

    if handle_post:
        handle_post(aliases, keys)


#####################################################################
def go2env(args, handlers_type, selector, handler_keyword_args,
           grep_regexps, serialized_file=DEFAULT_SERIALIZED_FILE,
           ostream=sys.stdout):
    """Simple entry-point tailored to command line interface."""

    dp_io.cdebug(1, "in go2env()\n")

    dp_io.cdebug(2, "args>%s<, handlers_type>%s<, selector>%s<, "
                  "handler_keyword_args>%s<, grep_regexps>%s<",
                  args, handlers_type, selector, handler_keyword_args,
                  grep_regexps)
    dp_io.cdebug(1, "handlers_type>{}<\n", handlers_type)
    handlers = get_handlers(handlers_type)
    handle, handle_pre, handle_post, selector_regexp = handlers[selector]
    if type(selector_regexp) == bytes:
        selector_regexp = selector_regexp
        # print >>sys.stderr, "handle>%s<" % handle

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


#####################################################################
# main
#####################################################################
def main(argv):
    #
    # parse args
    #
    suffix = ""
    selector = SELECTOR_ENV
    grep_regexps = []
    shortopts = 'efvdlLs:Eq:g:G:m:M:S:pP:aFuUrD:'
    longopts = ["grep-name-only=", "gno=",
                "grep-val-only=", "gvo="]
    opts, args = getopt.getopt(argv[1:], shortopts, longopts)
    handler_keyword_args = {}
    serialize_aliases_p = False
    serialized_file_name = DEFAULT_SERIALIZED_FILE_NAME
    write_dict_p = False
    force_read_file = True
    shell_type = Shell_type
    # @todo XXX Change this to a real arg parser.
    # @todo XXX Hack using long options, which is what I'm most desirous of.
    # @todo XXX Change this to a real arg parser.
    for opt, val in opts:
        if opt == '-e':
            selector = SELECTOR_EMACS
        elif opt == '-f':               # make file not found fatal
            ignore_file_not_found = 0
        elif opt == '-v':
            global verbose
            verbose += 1
        elif opt in ('-d', '-D'):
            global debug
            if opt == '-d':
                debug += 1
            else:
                debug = eval(val)
            print("debug set to: {}".format(debug), file=sys.stderr)
            dp_io.debug_on(debug)
        elif opt == "-l":               # Simple listing
            selector = SELECTOR_SIMPLE_LIST
        elif opt == "-L":          # Simple listing with file names displayed
            selector = SELECTOR_NAMES_LIST
        elif opt == '-s':
            shell_type = val            # Override $SHELL.
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
            shell_type = "grep"
        elif opt in ('--grep-name-only', '--gno'):
            grep_regexps.append(val)
            handler_keyword_args["grep-name-only"] = True
            shell_type = "grep"
        elif opt in ('--grep-val-only', '--gvo'):
            grep_regexps.append(val)
            handler_keyword_args["grep-val-only"] = True
            shell_type = "grep-val"
        elif opt == '-G':
            grep_regexps.append(val)
            handler_keyword_args["grep-val"] = True
            shell_type = "grep-val"
        elif opt == '-S':
            suffix = val
        elif opt == '-M':
            # specific.
            grep_regexps.append("^" + val + "__SB_rel$")
            shell_type = "grep"
        elif opt == '-m':
            grep_regexps.append("^" + val + suffix + "$")
            shell_type = "grep"
        elif opt == '-p':
            serialize_aliases_p = True
        elif opt == '-P':
            serialize_aliases_p = True
            serialized_file_name = val
        elif opt == '-a':
            write_dict_p = True
        elif opt == '-F':
            set_force_dict_updated_p(True)
        elif opt == '-u':
            handler_keyword_args["unset_var_first_p"] = True
        elif opt == '-U':
            handler_keyword_args["unset_var_p"] = True
        elif opt == '-r':
            force_read_file = True

    serialized_file = opath.join(os.environ["HOME"], "var", "db",
                                 serialized_file_name)
    dict_file = serialized_file + DEFAULT_DICT_EXT

    if serialize_aliases_p:
        serialize_aliases(args, serialized_file)
        sys.exit(0)
    if write_dict_p:
        write_dict(args, dict_file)
        sys.exit(0)

    go2env(args=args, handlers_type=shell_type, selector=selector,
           handler_keyword_args=handler_keyword_args,
           serialized_file=serialized_file,
           grep_regexps=grep_regexps)


if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        sys.exit(main(sys.argv))
    except IOError as e:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            # Not all apps care about getting an EPIPE?
            # Should we no consider it an error?
            print(":Broken PIPE:", file=sys.stderr)
            sys.exit(errno.EPIPE)
        else:
            print("IOError>{}<", e, file=sys.stderr)
            sys.exit(errno.EIO)
