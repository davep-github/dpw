#!/usr/bin/env python

import os, sys, string, re, getopt, dp_io, types

ignore_file_not_found = 1
emacs_abbrev_table_name = 'dp-go-abbrev-table'
verbose = 0
debug = 0

ELISP_OUTPUT_HANDLER_FLAGS = "elisp output handler flags"
ELISP_EMIT_SETENV = "elisp output setenv"

PERMANENT_PREFIX = ""
PREFIX = ""
HOME = os.environ['HOME']
UGLY_HOME = dp_io.bq('cd $HOME; /bin/pwd')[:-1]
Shell_type = None                       # None means use $SHELL

Evil_globals = {}

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
    
#dp_io.eprintf('HOME>%s<, UGLY_HOME>%s<', HOME, UGLY_HOME)

def handle_env_var(fmt, name, open_quote,val, close_quote, **kwargs):
    flags = kwargs.get(ELISP_OUTPUT_HANDLER_FLAGS, None)
    emit_setenv_p = False
    if flags:
        emit_setenv_p = flags.val()
    if emit_setenv_p:
        print '(setenv "%s" %s%s%s)' % (name, open_quote, val, close_quote)
    else:
        print fmt  % (name, open_quote, val, close_quote, name)
    
#####################################################################
def handle_sh(name, val, **kw_args):
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
def handle_csh(name, val, **kw_args):
    #
    # There are two kinds of environment outputs:
    # 1. Shell
    # B. elisp setenv calls
    # The format to handle_env_var needs to take 3 parameters.
    # We just suck the 3rd into a comment.
    handle_env_var('setenv %s "%s"; # %s\n', name, val, **kw_args)

def emacs_pre(**kwargs):
    print '(setq ' + emacs_abbrev_table_name + ' (make-abbrev-table))'

#####################################################################
def handle_emacs(name, val, **kw_args):
    """Emacs won't look past non-alpha numeric when expanding aliases,
    so we nuke those chars here."""
    name = re.sub('[^a-zA-Z0-9]', '', name)
    # print '(define-abbrev %s "%s" "\\"%s\\"" nil 1)' % \
    # (emacs_abbrev_table_name, name, val)
    print '(define-abbrev %s "%s" "%s" nil 1)' % \
          (emacs_abbrev_table_name, name, val)

#####################################################################
#
def handle_print(name, val, **kw_args):
    print val

#####################################################################
#
def handle_grep_name(name, val, **kw_args):
    regexp = kw_args.get("regexp", ".*")
    if re.search(regexp, name):
        handle_print(name, val, **kw_args)

#####################################################################
#
def handle_grep_val(name, val, **kw_args):
    regexp = kw_args.get("regexp", ".*")
    sys.exit(99)
    if re.search(regexp, val):
        handle_print(name, val, **kw_args)

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
        print >>sys.stderr, "SHELL>%s<" % (shell,)
    shell_name = os.path.basename(shell)
    try:
        return shell_handlers[shell_name]
    except:
        dp_io.eprintf('*** Unknown shell>%s<\n',  shell)
        (None, None, None)

#####################################################################
def list_handler(name, val, file_name, ctl, **kw_args):
    """Simple listing to stdout."""
    print val, name, file_name, ctl

def LIST_handler(name, val, file_name, ctl, **kw_args):
    print "%s:%s" % (file_name,  val), name, file_name, ctl

#
# handlers map.
# key: selector char in .go file
# val: list of handlers for selector:
#   entry, prefix in file, suffix in file, selector-regexp
def get_handlers(shell_type=None):
    if shell_type == None:
        shell_type = Shell_type
    return { 'E': (handle_emacs, emacs_pre, None, "E"),
             'e': environment_var_handler(shell_type) + ("e",),
             'p': (prefix_handler, None, None, "p"),
             'P': (permanent_prefix_handler, None, None, "P"),
             'l': (list_handler, None, None, "E|e"),
             'L': (LIST_handler, None, None, "E|e"),
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
    # ctl|alias0[|alias1...]
    # ctl says what kind of alias this is, e.g. emacs or environment
    l = m.group(1)
    val = m.group(2)
    var_name = val
    ##print >> sys.stderr, "l>%s<" % (l,)
    l = string.split(l, '|')
    ##print >> sys.stderr, "split l>%s<" % (l,)
    ctl = l[0]
    if selector.search(ctl):
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
                aliases[name] = (val,
                                 {"line": line, "selector": selector,
                                  "ctl": ctl, "aliases": aliases,
                                  "file_name": file_name})


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
def expand_files(files, selector, aliases):
    """Expand a list of files."""
    for file in files:
        expand_file(file, selector, aliases)


#
# parse args
#
selector = 'e'
grep_regexp = None
opts, args = getopt.getopt(sys.argv[1:], 'efvdlLs:Eq:g:G:m:')
handler_keyword_args = {}
for opt, val in opts:
    if opt == '-e':
        selector = 'E'
    elif opt == '-f':                   # make file not found fatal
        ignore_file_not_found = 0
    elif opt == '-v':
    	verbose += 1
    elif opt == '-d':
        debug += 1
        dp_io.debug_on()
    elif opt == "-l":                   # Simple listing
        selector = 'l'
    elif opt == "-L":              # Simple listing with file names displayed
        selector = 'L'
    elif opt == '-s':
        Shell_type = val                # Override $SHELL.
    elif opt == '-E':
        selector = 'e'
        # Generate (setenv "bubba" "blah") calls.
        handler_keyword_args[ELISP_OUTPUT_HANDLER_FLAGS] = \
            Keyword_option_t(ELISP_EMIT_SETENV, True)
    elif opt == '-q':
        Evil_globals["quote_char"] = val
    elif opt == '-g':
        grep_regexp = val
        Shell_type = "grep"
    elif opt == '-G':
        grep_regexp = val
        Shell_type = "grep-val"
    elif opt == '-m':
        # Do this with a front end since it is nvidia ME specific.
        grep_regexp = "^" + val + "__SB_rel$"
        Shell_type = "grep"

handlers = get_handlers(Shell_type)

#
# find the go path
# The gopath looks like this:
# /udir/davep/.go.ping:/udir/davep/.go.crl:/udir/davep/.go
# most specific to least.  This is good when searching the gopath
# directly.  For generating variables, we reverse the list so that
# more specific files can override less specific ones.
# dogo stops at the first match, and this produces the same effect.
#
files = []
names = []
if args:
    i = 0
    for arg in args:
        i += 1
        if arg == '--':
            break
        files.append(arg)
    args = args[i:]
    for arg in args:
        names.append(arg)
if not files:
    if os.environ.get('GOPATH'):
        files = string.split(os.environ.get('GOPATH'), ':')
    else:
        files = [os.environ.get('HOME') + '/.go']

if not files:
    print >>sys.stderr, "No go files. Exiting."
    sys.exit(1)

files.reverse()

aliases = {}

handle, handle_pre, handle_post, selector_regexp = handlers[selector]
if type(selector_regexp) == types.StringType:
    selector_regexp = re.compile(selector_regexp)
#print >>sys.stderr, "handle>%s<" % handle

expand_files(files, selector_regexp, aliases)

keys = aliases.keys()
keys.sort()

##!<@todo Stash away file name for better location purposes.

if handle_pre:
    handle_pre(**handler_keyword_args)

for k in keys:
    kwargs = handler_keyword_args
    kwargs.update(aliases[k][1])
    kwargs["regexp"] = grep_regexp
    #print >>sys.stderr, "kwargs:", kwargs
    handle(k, aliases[k][0], **kwargs)

if handle_post:
    handle_post(aliases, keys)
