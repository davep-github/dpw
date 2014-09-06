#!/usr/bin/env python

import time, re, string, sys, dp_io
from opts import *

#
# access the database
#
import dppydb
#db=dbt
dppydb.prep()

completed_pat = re.compile('^(yes|[1ty])$', re.IGNORECASE)

todo_file_header = """
import types

# import class defs for entries and databases
import dppydb
#db=dbt

#
# create the db.
#
DB = dppydb.PythonDataBase()

#
# shorthand for var to construct and add new record to db
#
def e(dat):
    global seq_num
    dat['seq_num'] = `seq_num`
    DB.add(dat=dat, kef='seq_num')
    seq_num += 1

def complete(seq, date='after the big bang', comment=''):
    if type(seq) == types.IntType:
        seq = `seq`
        
    DB[seq].add_fields(completed='yes', completion_date=date, comment=comment)

#
# this list can grow by adding new entries at the end.
# we can add calls to complete to mark an item as complete.
# complete calls must refer back to an existing entry
# We can also complete an item by adding the completed field
# to the original entry.
#

seq_num = 0

# the todos...

"""

#
# todo... add/complete/annotate todo items.
#

def is_completed(ent):
    try:
        return completed_pat.search(ent['completed'])
    except KeyError:
        return 0                        # no completed field -> not completed
    
def get_completed_list(db):
    return db.grep_fields(pat='completed', vpat=completed_pat)

def get_todo_list(db):
    elist = db.grep_fields()
    olist = []
    for ent in elist:
        if not is_completed(ent):
            olist.append(ent)
            
    return olist

def display_elist(elist):
    for e in elist:
        if not display_pat:
            if is_completed(e):
                cstring = 'C: '
            else:
                cstring = ''
            print '%3d: %s%s' % (eval(e['seq_num']), cstring, e['todo']),
            try:
                s = e['comment']
                print ' comment:', s
            except:
                pass
            print '\n--'
        else:
            e.print_fields(display_pat)
        
def list_completed(db):
    print 'Completed todos:'
    elist = get_completed_list(db)
    display_elist(elist)

def list_all(db):
    print 'All todos:'
    elist = db.grep_fields()
    display_elist(elist)

def list_todo(db):
    print 'Todos left todo:'
    olist = get_todo_list(db)
    display_elist(olist)

def purge_completed(db):
    olist = get_todo_list(db)
    print todo_file_header
    for e in olist:
        print 'e(\n    dat={'
        fields = e.ret_fields()
        keys = fields.keys()
        keys.sort()
        for f in keys:
            if f == 'seq_num':
                continue
            print '''    '%s': """%s""",''' % (f, fields[f])

        print '    })'

def complete_todo(db, seq, comment):
    # verify seq exists
    try:
        item = db[seq]
    except KeyError:
        print >>sys.stderr, 'sequence number %s is not in the todo list.' % seq
        #db.dump('seq not found')
        sys.exit(3)
        
    fname = dppydb.find_db_file('todo_db', localize=1)[0]
    # print 'file>%s<' % fname
    f = open(fname, 'a')
    s = "\ncomplete(%s, %s, comment=%s)\n" % (seq, `time.ctime(time.time())`,
                                              `comment`)
    #print 's>%s<' % s
    f.write(s)
    f.close()
    print "completed: `%s'" % item['todo']

def add_todo(db, todo):
    if todo == '-':
        dp_io.debug('reading todo from stdin')
        todo = sys.stdin.read()
        dp_io.debug('todo from stdin>%s<\n', todo)
    
    s = '''
e(
    dat={
    'todo': %s,
    'added': '%s',
    })
''' % (`todo`, time.ctime(time.time()))
    
    if options.to_stdout:
        print 's>%s<' % s
    else:
        fname = dppydb.find_db_file('todo_db', localize=1)[0]
        if options.verbose:
            print 's>%s<' % s
            print 'writing todo to %s...' % fname
        f = open(fname, 'a')
        f.write(s)
        f.close()
    
def usage():
    print """Manipulate todo database
usage: todo [options] [todo-item-text]

options:"""
    
    try:
        print opts_help(qopts)
    except NameError:
        # options is not defined yet.
        print >>sys.stderr, 'qopts not defined yet.'
        
    sys.exit(109)

qopts = [
    # FlagOptions
    # opt-char, opt-name, if-set-val, default-val, help-string
    # e.g. FlagOption('f', 'use_fifo', 1, 0, 'Use fifo vs sio'),
    FlagOption('h?H', 'help_req', 1, 0, 'Get help.'),
    FlagOption('C', 'show_completed', 1, 0, 'Show completed entries.'),
    FlagOption('a', 'show_all', 1, 0, 'Show all entries.'),
    FlagOption('p', 'purge_completed', 1, 0,
               """Purge all completed entries.  This is done by emitting all
	uncompleted todos to stdout along with the necessary database
	initialzation code."""),
    FlagOption('v', 'verbose_list', 1, 0, 'Display all todo fields'),
    FlagOption('O', 'show_opts', 1, 0, 'Show option values after parsing.'),
    FlagOption('t', 'to_stdout', 1, 0, 'Print todo to stdout.'),
    FlagOption('e', 'verbose', 1, 0, 'Also show todo to stdout.'),

    ArgOption('c', 'completed_list', opts_add_to_list, [],
              'Add sequence number to list of items to mark as complete.'),
    ArgOption('d', 'db_wilds', opts_add_to_list, [],
              'Add arg to list of wildcards to match '
              'for databases to examine.'),
    ArgOption('D', 'db_dirs', opts_add_to_list, [],
              'Add dir to database search path.'),
    ]

options = Options(sys.argv, qopts, usage=usage)
if options.help_req:
    usage()
if options.show_opts:
    print options.help()

if not options.db_wilds:
    wilds='todo_db'
else:
    wilds = options.db_wilds
if not options.db_dirs:
    options.db_dirs = None
db = dppydb.load(dirs=options.db_dirs, wild=wilds)

if options.verbose_list:
    display_pat = '.*'
else:
    display_pat = None

if display_pat:
    display_pat = re.compile(display_pat)

if options.completed_list:
    for seq in options.completed_list:
        complete_todo(db, seq, string.join(options.args, ' '))
elif options.purge_completed:
    purge_completed(db)
elif options.show_all:
    list_all(db)
elif options.show_completed:
    list_completed(db)
elif not options.args :
    list_todo(db)
elif options.args:
    add_todo(db, string.join(options.args, ' '))
             
sys.exit(0)
