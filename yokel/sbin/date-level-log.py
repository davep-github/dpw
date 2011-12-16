#!/usr/bin/env python
#
# $Id: date-level-log.py,v 1.4 2004/03/12 06:16:26 davep Exp $
#
import sys, os, string, re, time, getopt, dp_io

#
# Maintain a log of dates on which actions of a particular level
#  was performed on src.
# This is based on the dumpdates file used by dump(8)
#
# args: -a src level date
#   add a record for src that level was done on date
# args: -d src level --> date
#   return date for src when level was done

EPOCH_DEF = time.ctime(0)
EPOCH = EPOCH_DEF

Auto_create = True

#
# Hash of lists indexed by src.
# Each list is a list of dates indexed by level
#
# self.log{src} -> [ date-for-level0, date-for-level1, ...]
#
class Date_Log_File:
    def __init__(self, file_name, max_levels=99):
        self.file_name = file_name
        self.max_levels = max_levels
        self.log = {}
        if Auto_create:
            try:
                os.stat(self.file_name)
            except OSError, e:
                print >>sys.stderr, 'Cannot stat "%s". Will try to create it.' % self.file_name
                open(self.file_name, 'w').close()

    def parse_line(self, line):
        l = string.split(line)
        src = l[0]
        level = eval(l[1])
        date = string.join(l[2:], ' ')
        # time_tuple = time.strptime(date)
        # time_t = time.mktime(time_tuple)
        return (src, level, date) # , time_t)

    def get_or_create_date_list(self, src):
        try:
            list = self.log[src]
        except KeyError:
            # no such key, create all empty
            self.log[src] = [None] * self.max_levels
            list = self.log[src]

        return list

        
    def read(self):
        file = open(self.file_name, "r")
        while 1:
            line = file.readline()
            if not line:
                break
            # discard comment lines
            if re.search('^\s*#', line):
                continue
            # discard comment part of line
            m = re.search('(^[^#]*)', line)
            if m and m.group(0) and m.group(0) != '\n':
                src, level, date = self.parse_line(m.group(0))
                list = self.get_or_create_date_list(src)
                list[level] = date

        file.close()
        

    def date_for_level(self, src, target_level):
        try:
            list = self.log[src]
        except KeyError:
            return EPOCH

        # search for greatest level <= desired level
        for level in xrange(target_level-1, -1, -1):
            if list[level] != None:
                return list[level]
            
        return EPOCH

    def add_or_update_level(self, src, level, date):
        list = self.get_or_create_date_list(src)
        list[level] = date

    def write_header(self, file):
        s = '#\n# File written on: %s\n#\n' % time.ctime(time.time())
        s = s + '# format: src_dir  level  date  [# comment]\n#\n'
        file.write(s)

        
    def write(self):
        file = open(self.file_name, "w")
        keys = self.log.keys()
        keys.sort()
        self.write_header(file)
        for key in keys:
            list = self.log[key]
            file.write("# dates for `%s'\n" % key)
            for level in xrange(0, self.max_levels):
                if list[level] != None:
                    s = '%-35s\t%3d  %s\n' % (key, level, list[level])
                    file.write(s)
            file.write('\n')

        file.close()
            
#
# -d src level
# -a src level date
#

progname = re.search('([^/]+)$', sys.argv[0])
progname = progname.group(0)

do_add = None
do_date = None
do_inc = None
log_file = '/home/davep/tmp/dl_file'    # default for testing
output_format = None
max_levels = 99
epoch_set = None

options, args = getopt.getopt(sys.argv[1:], 'daf:F:E:M:iA:')
for opt, val in options:
    #print 'opt', opt, 'val', val
    if (opt == '-d'):
        do_date = 1
    elif (opt == '-a'):
        do_add = 1
    elif (opt == '-f'):
        log_file = val
    elif (opt == '-F'):
        output_format = val
    elif (opt == '-E'):
        EPOCH=val
        epoch_set = 1
    elif (opt == '-M'):
        max_levels = eval(val)
    elif (opt == '-i'):
        do_inc = 1
    elif (opt == '-A'):
        Auto_create = eval(v)

log_file = Date_Log_File(log_file, max_levels)
log_file.read()

try:
    src = args[0]
    level = eval(args[1])
except IndexError:
    if not do_inc or do_add or do_date:
        dp_io.eprintf('%s: not enough args\n', progname)
        sys.exit(1)

if len(args) > 2:
    date = string.join(args[2:], ' ')
else:
    date = None
    
if do_add:
    if date == None:
        dp_io.eprintf('%s: no date given for add option.\n', sys.argv[0])
        sys.exit(1)
        
    log_file.add_or_update_level(src, level, date)
    log_file.write(
        )

if do_date:
    #print 'doing date, of>%s<' % output_format
    d = log_file.date_for_level(src, level)
    if output_format:
        #print 'output_format>%s<, d>%s<' % (output_format, d)
        try:
            #print 'aaa, d>%s<' % d
            time_tuple = time.strptime(d)
            #print 'bbb'
            #print 'time_tuple>%s<' % time_tuple
            d = time.strftime(output_format, time_tuple)
        except ValueError:
            # send value sans formatting
            #print "fmt error"
            pass
            
    print d

if do_inc:
    if not epoch_set:
        EPOCH = '0'
    d = eval(log_file.date_for_level(src, 1))
    log_file.add_or_update_level(src, 0, d+1)
    log_file.write()
    
sys.exit(0)
