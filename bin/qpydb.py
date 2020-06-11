#!/usr/bin/env python

#
# generically query python databases
#
import os, sys, getopt, string
from opts import *

import dppydb
#db=dbt

formatter = None

def val_formatter(prefix, field, value):
    return value

def field_printer(database, entry):
    if formatter:
        entry.print_fields(options.print_field_pat,
                           options.print_val_pat,
                           sortem=options.print_sorted,
                           formatter=formatter)
    else:
        entry.print_fields(options.print_field_pat,
                           options.print_val_pat,
                           sortem=options.print_sorted)
        
def val_printer(database, entry):
    d = entry.ret_fields(options.print_field_pat, options.print_val_pat)
    for k in list(d.keys()):
        print(d[k])

def set_handler(handler_var, handler_func_name, default=None):
    try:
        funcp = sys.modules[modname].__dict__[handler_func_name]
    except KeyError:
        funcp = default
    globals()[handler_var] = funcp

    
def usage():
    print("""Query python databases\noptions:\n""")
    try:
        print(opts_help(qopts))
    except NameError:
        # options is not defined yet.
        sys.stderr.write('qopts not defined yet.')
        
    sys.exit(109)

    
qopts = [
    # FlagOptions
    # opt-char, opt-name, if-set-val, default-val, help-string
    # e.g. FlagOption('f', 'use_fifo', 1, 0, 'Use fifo vs sio'),
    FlagOption('h?H', 'help_req', 1, 0, 'Get help.'),
    FlagOption('O', 'show_opts', 1, 0, 'Show option values after parsing.'),
    FlagOption('s', 'print_vals', 1, 0,
               'Print values of selected fields only.'),
    FlagOption('S', 'print_sorted', 1, 0,
               'For default processor, print fields in sorted order.'),

    # ArgOptions
    # opt-char, opt-name, how-to-set, default-val, help-string
    # e.g. ArgOption('b', 'baud', map_baud, TERMIOS.B38400, 'Baud rate'),
    ArgOption('f', 'field_pat', None, None,
              'Select entries with field names matching pattern.'),
    ArgOption('v', 'val_pat', None, None,
              'Select entries with field values matching pattern.'),
    ArgOption('F', 'print_field_pat', None, None,
              "Print matching entries' fields w/names matching pattern."),
    ArgOption('V', 'print_val_pat', None, None,
              "Print matching entries' fields w/values matching pattern."),
    ArgOption('e', 'entry_processing_file', None, None,
              'Select file with python code to process matching entries.'),
    ArgOption('d', 'db_wilds', opts_add_to_list, [],
              'Add arg to list of wildcards to match '
              'for databases to examine.'),
    ArgOption('p', 'db_pats', opts_add_to_list, [],
              'Add arg to list of re patterns to match '
              'for databases to examine.'),
    ArgOption('D', 'db_dirs', opts_add_to_list, [],
              'Add dir to database search path.'),
    ArgOption('q', 'verbose', opts_intval, 0, 'Set verbosity level.'),
    ]

options = Options(sys.argv, qopts, usage=usage)
if options.help_req:
    usage()

if options.show_opts:
    print(options.help())

dppydb.prep()

if not options.db_pats:
    pat=None
else:
    pat = string.join(options.db_path, '|')

if not options.db_wilds:
    wilds=None
else:
    wilds = options.db_wilds

if options.show_opts:
    print('pattern for db selection>%s<' % pat)
    print('wildcards for db selection>%s<' % wilds)

if not options.db_dirs:
    options.db_dirs = None

d = dppydb.load(dirs=options.db_dirs, pat=pat, wild=wilds,
                verbose=options.verbose)
        
#
# get the matching entries...
#
ents = d.grep_fields(options.field_pat, options.val_pat)

if options.entry_processing_file:
    modname, modext = os.path.splitext(options.entry_processing_file)
    exec('import %s' % modname)
    # required
    entry_processor = sys.modules[modname].main

    #optional
    set_handler('init_handler', 'init', None)
    set_handler('fini_handler', 'fini', None)
    set_handler('eof_handler', 'handle_eof', None)
        
else:
    if options.print_vals:
        entry_processor = val_printer
    else:
        entry_processor = field_printer

    eof_handler = None
    init_handler = None
    fini_handler = None

#
# & awaaaay we go!
#
if init_handler:
    init_handler(d)
    
# process the selected fields
for ent in ents:
    entry_processor(d, ent)
    
if eof_handler:
    eof_handler(d)
    
if fini_handler:
    fini_handler(d)
