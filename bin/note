#!/usr/bin/env python

"""notes.py
A system built on top of dppydb for keeping track of notes.  Notes are
simple thoughts, ideas, facts, etc. that are worth saving.
In order to facilitate recollection of these notes, a bunch of information
is automatically  saved with each note: the date, the node, the current
dir, etc.
Optional info can be added to: keywords, people involved with the item, etc.

Hopefully some of this will help when you need to recall the information.
E.g.:
I remember it was a few weeks ago:  use a date range.
I remember I was at work: use the node name of your work machine.
I remember I was working on project X: use the dirname of project X.
Etc.  As other things that may help recollection are discovered, they
can be added."""

OVW_OPT = 'o'

#
# when we create a new database there is a slight timing problem.
# Once we create the db, we immediately "open" it, which causes it to
# to be byte-compiled by python.
# Any record written soon thereafter will not cause the .py to be older
# than the .pyc, so we wait 2 seconds to guarantee that the time advances
# at least one second which is the granularity of the file mod time.
# This flag tells us to do the wait.
#
created_hack = 0

import time, re, string, sys, os, getpass, dp_time, types, dp_io
from opts import *

progname = os.path.basename(sys.argv[0])

#
# access the database
#
import dppydb
dppydb.prep()

# keep 1 db/month named notes_<mon-abbrev>_<year+century>
# get the time when we start so in case we cross midnight into
# another month we won't end up with file name confusion.
#
note_time = time.time()
db_file = 'notes_%s' % time.strftime('%b_%Y', time.localtime(note_time))

#################################################################
#
# The notes file header.  This is used to start each notes database
# file.
# It contains some id info and some definitions for use with the
# dppydb system.
#
pydb_file_header = """
#
# file created by %s
# file created on %s
# file name: %s.py
#
import types

# import class defs for entries and databases
import dppydb

# create the db.
#
DB = dppydb.PythonDataBase()

#
# shorthand for constructor
#
e = DB.add

# the notes

""" % (progname, time.ctime(note_time), db_file)

#################################################################
#
# time_t = time.mktime(time.strptime(timestr, '%m/%d/%Y')) - time.timezone
# --> time in sec since epoch UTC (as returned by time.time()
# We can now do comparisons on time_t field of the note.
#
def to_time_t(tim, default):
    if tim:
        tim = dp_time.parse_date(tim, note_time, tz_adjust=dp_time.LOCAL)
        if tim:
            return tim
        else:
            dp_io.eprintf('Unrecognizable time/date format >%s<\n', tim)
            sys.exit(2)
    else:
        return default

#################################################################
def process_date_ranges(starts, ends):
    """equalize the lens of the start and end date lists.
    add nows to end dates and 0s to starts.
    Selecting all before a particular date can be done with a single -e date.
    Selecting ll after a particular date can be done with a single -s date.
    Return a list of (start, end) tuples"""
    
    ret = []
    diff = len(starts) - len(ends)
    if diff > 0:
        while diff:
            ends.append(None)
            diff = diff - 1
    elif diff < 0:
        while diff:
            starts.append(None)
            diff = diff + 1

    for i in xrange(len(starts)):
        start = to_time_t(starts[i], 0)
        end = to_time_t(ends[i], note_time)
        ret.append((start, end))

    if options.debug:
        for start, end in ret:
            print '%s ... %s' % (time.ctime(start), time.ctime(end))
    return ret
    
#################################################################
def create_new_db(db_file, overwrite=0, silent=0):
    dirs = dppydb.get_db_dirs(options.db_dirs)
    if options.debug:
        print 'dirs>%s<' % (dirs,)
    dir = dirs[0]
    if not dir:
        dp_io.eprintf('Cannot find db dir.   Please specify a location.\n')
        sys.exit(1)
    fname = os.path.normpath(dir + '/' + db_file + '.py')
    if os.path.exists(fname) and not overwrite:
        if silent:
            return
        else:
            dp_io.eprintf('file>%s< already exists.\n', fname)
            dp_io.eprintf("  specify the overwrite option `-%s' to overwrite it.\n", OVW_OPT)
            sys.exit(2)
        
    f = open(fname, 'w')
    f.write(pydb_file_header)
    if options.debug:
        print 'created>%s<' % fname
    global created_hack
    created_hack = 1
    f.close()

#################################################################
def in_date_range(date, ranges):
    """in_date_range(date, ranges)
    A date match will occur if a note date is contained in
    any of the start/end pairs."""

    if type(date) == types.StringType:
        date = eval(date)
        
    for start, end in ranges:
        if options.debug:
            c = time.ctime
            print 'date:', date, 'start:', start, 'end:', end
            if options.debug > 1:
                print 'date:', c(date), 'start:', c(start), 'end:', c(end)

        if date >= start and date <= end:
            return (start, end)
    return ()

#################################################################
def display_note(note, pat=None, vpat=None):
    d = note.ret_fields(fields_to_print_pat)
    keys = d.keys()
    keys.sort()
    for k in keys:
        dat = d[k]
        if vpat and options.hilight_matches:
            dat = dp_io.hilight_match(dat, vpat)
        print "%s: `%s'" % (k, dat)
    print '--'
    
#################################################################
def display_elist(elist):
    for e in elist:
        display_note(e)
        
#################################################################
def list_all(db):
    print 'All notes:'
    for e in db:
        display_note(e)

#################################################################
def list_some(db, pat, vpat, date_ranges):
    print 'Notes:'
    olist = db.grep_fields(pat, vpat)
    for e in olist:
        if not date_ranges or in_date_range(e['time_t'], date_ranges):
            display_note(e, vpat=vpat)

#################################################################
def get_hostname():
    return os.uname()[1]
    
#################################################################
def add_item(db, note, **kargs):
    fname = dppydb.find_db_file(db_file, localize=1)[0]

    if note == '-':
        dp_io.debug('reading note from stdin')
        note = sys.stdin.read()
        dp_io.debug('note from stdin>%s<\n', note)
    #
    # add all of the standard fields.
    #
    # 'note': """%s""",

    dat = '''dat={
    'note': %s,
    'date': """%s""",
    'time_t': """%s""",
    'node': """%s""",
    'dir': """%s""",
    'user': """%s""",
''' % (`note`, time.ctime(note_time), `note_time`, get_hostname(),
       os.getcwd(), getpass.getuser())

    #
    # add any optional fields.
    # the parameter name will be the key name
    # 
    for key in kargs.keys():
        val = kargs[key]
        if val:
            dat = dat + '''    '%s': """%s""",\n''' % (key, val)
    s = '''
e(
    %s    })
''' % dat
    if options.to_stdout:
        print '%s' % s
    else:
        f = open(fname, 'a')
        if created_hack:
            time.sleep(2)
        f.write(s)
        f.close()
    
#################################################################
def usage():
    print """Manipulate notes database
usage: %s [options] [item-text]

options:""" % (progname,)
    
    try:
        print opts_help(qopts)
    except NameError:
        # options is not defined yet.
        dp_io.eprintf('qopts not defined yet.\n')
        
    sys.exit(109)

#################################################################
qopts = [
    # FlagOptions
    # opt-char, opt-name, if-set-val, default-val, help-string
    # e.g. FlagOption('f', 'use_fifo', 1, 0, 'Use fifo vs sio'),
    FlagOption('?H', 'help_req', 1, 0, 'Get help.'),
    FlagOption('a', 'show_all', 1, 0, 'Show all entries.'),
    FlagOption('V', 'verbose_list', 1, 0, 'Display all note fields'),
    FlagOption('O', 'show_opts', 1, 0, 'Show option values after parsing.'),
    FlagOption('n', 'add_new_item', 1, 0, 'Add a new item.'),
    FlagOption('C', 'create_new_db', 1, 0, 'Create a new, empty db file.'),
    FlagOption(OVW_OPT, 'create_new_db_overwrite', 1, 0,
               'Allow -C to overwrite and existing db.'),
    FlagOption('h', 'hilight_matches', 0, 1, 'Should matches be highlighted.'),
    FlagOption('t', 'to_stdout', 1, 0, 'Write new item to stdout.'),

    ArgOption('f', 'field_pat', None, None, 'Pattern for field selection.'),
    ArgOption('v', 'val_pat', None, None, 'Pattern for value selection.'),
    ArgOption('d', 'db_wilds', opts_add_to_list, [],
              'Add arg to list of wildcards to match '
              'for databases to examine.'),
    ArgOption('D', 'db_dirs', opts_add_to_list, [],
              'Add dir to database search path.'),
    ArgOption('p', 'people', opts_add_to_list, [],
              'Add arg to people list.'),
    ArgOption('k', 'keys', opts_add_to_list, [],
              'Add arg to keys list.'),
    ArgOption('s', 'start_dates', opts_add_to_list, [],
              'Save a start date.'),
    ArgOption('F', 'fields_to_print', opts_add_to_list, [],
              'Add a pattern to the list of fields to print.'),
    ArgOption('e', 'end_dates', opts_add_to_list, [],
              'Save an end date.'),
    ArgOption('b', 'debug', opts_intval, 0, 'Set debug/trace variable'),
    ArgOption('c', 'creation_loc', None, None, 'Set creation location.'),
    ]

options = Options(sys.argv, qopts, usage=usage)

if options.help_req:
    usage()
if options.show_opts:
    print options.help()

#
# ensure the db exists.
# we keep one db/month
# so try to create it, but don't fail if it exists
#
if not options.to_stdout:
    create_new_db(db_file, overwrite=0, silent=1)


date_pairs = process_date_ranges(options.start_dates, options.end_dates)

if not options.db_wilds:
    wilds='notes_*'
else:
    wilds = options.db_wilds
if not options.db_dirs:
    options.db_dirs = None
db = dppydb.load(dirs=options.db_dirs, wild=wilds,
                 verbose=options.debug, localize=1)

if options.debug > 2:
    db.dump('just loaded')

# determine which fields to print
if options.verbose_list:
    fields_to_print_pat = None          # show all fields
elif options.fields_to_print != []:
    fields_to_print_pat = string.join(options.fields_to_print, '|')
else:
    fields_to_print_pat = '^note$'      # show only `useful' fields

if options.show_opts:
    print 'fields_to_print_pat>%s<' % fields_to_print_pat

if fields_to_print_pat:
    fields_to_print_pat = re.compile(fields_to_print_pat)

if options.create_new_db:
    create_new_db(db_file, options.create_new_db_overwrite)
elif options.add_new_item:
    add_item(db,
             note=string.join(options.args, ' '),
             people=string.join(options.people, ' '),
             keys=string.join(options.keys, ' '),
             creation_loc=options.creation_loc)
elif options.show_all:
    list_all(db)
else:
    if not options.val_pat:
        options.val_pat = string.join(options.args, ' ')
    if options.debug:
        print 'options.val_pat>%s<' % options.val_pat
    list_some(db, pat=options.field_pat, vpat=options.val_pat,
              date_ranges=date_pairs)
             
sys.exit(0)
