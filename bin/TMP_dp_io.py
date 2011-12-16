#!/usr/bin/env python
# $Id: dp_io.py,v 1.15 2002/12/25 08:30:15 davep Exp $
#
import re, types, os, sys

f_debug = 0
f_eprint = 1
f_print = 1

v_debug_files = [sys.stderr]
v_eprint_files = [sys.stderr]
v_print_files = [sys.stdout]

debug_leader = 'debug'
debug_leader_sep = ': '
eprint_leader = ''
print_leader = ''

debug_level = -1

osname = os.uname()[0]
BOLD = ""
SOUT = ""
NORM = ""

if os.environ.get('TERM', None):
    if osname in ('FreeBSD',):
        BOLD = os.popen('tput md').read()
        SOUT = os.popen('tput so').read()
        NORM = os.popen('tput me').read()
    elif osname in ('Linux',):
        BOLD = os.popen('tput bold').read()
        SOUT = os.popen('tput bold').read()
        NORM = os.popen('tput rmso').read()

###############################################################
def hilight_match(dat, rex, pre=SOUT, post=NORM):
    """Highlight substrings of dat which match rex.
Highlighing is performed by emitting pre, the text to be highlihted, and
then post."""
    if type(rex) == types.StringType:
        rex = re.compile(rex)
    ostr = ''
    while dat:
        m = rex.search(dat)
        if not m:
            ostr = ostr + dat
            break
        # print leading part which didn't match
        ostr = ostr + dat[:m.start()]
        ostr = ostr + '%s%s%s' % (pre, dat[m.start():m.end()], post)
        dat = dat[m.end():]
    return ostr

###############################################################
def lprint(files, leader, s):
    """print leader + s to each file in <files> flushing each file."""
    s = leader + s
    for file in files:
        file.write(s)
        file.flush()

###############################################################
def eprintf(fmt, *args):
    """eprintf - print to stderr or user specified error files."""
    if f_eprint:
        if args:
            fmt = fmt % args
        lprint(v_eprint_files, eprint_leader, fmt)

###############################################################
def printf(fmt, *args):
    if f_print:
        if args:
            fmt = fmt % args
        lprint(v_print_files, print_leader, fmt)

###############################################################
def fprintf(ofiles, fmt, *args):
    if f_print:
        if args:
            fmt = fmt % args
        lprint(ofiles, print_leader, fmt)

###############################################################
def do_debug(fmt, leader, args):
    if f_debug:
        if args:
            fmt = fmt % args
        lprint(v_debug_files, leader+debug_leader_sep, fmt)
    
###############################################################
def debug(fmt, *args):
    do_debug(fmt, debug_leader, args)
    
###############################################################
def cdebug(level, fmt, *args):
    if debug_level >= level:
        do_debug(fmt, '%s[%02d]' % (debug_leader, level), args)
        
# alias
dprintf = debug

###############################################################
def set_debug(onoff=1):
    global f_debug
    f_debug = onoff

###############################################################
def debug_off():
    set_debug(0)

###############################################################
def debug_on():
    set_debug(1)

###############################################################
def set_debug_level(level):
    debug_level = level

###############################################################
def set_eprint(onoff=1):
    global f_eprint
    f_eprint = onoff

###############################################################
def eprint_off():
    set_eprint(0)

###############################################################
def eprint_on():
    set_eprint(1)

###############################################################
def set_print(onoff=1):
    global f_print
    f_print = onoff

###############################################################
def print_off():
    set_print(0)

###############################################################
def print_on():
    set_print(1)

###############################################################
def set_ofiles(file, flist, append=0):
    """file can be a string == filename,
    a tuple (filename, open-mode) or
    an open file object.
    Append says to append the file to the list of files."""
    if not append:
        del flist[:]
    mode = 'w'
    fname = ''
    if (type(file) == types.ListType) or (type(file) == types.TupleType):
        fname = file[0]
        mode = file[1]
    elif type(file) == types.StringType:
        fname = file
    if fname:
        try:
            file = open(fname, mode)
        except Exception, e:
            sys.stderr.write('could not open %s, e: %s\n' % (fname, e))
            return
    flist.append(file)
    
###############################################################
def debug_file(file, append=0):
    set_ofiles(file, v_debug_files, append)
    
###############################################################
def eprint_file(file, append=0):
    set_ofiles(file, v_eprint_files, append)

###############################################################
def print_file(file, append=0):
    set_ofiles(file, v_print_files, append)
    
###############################################################
def dump_vars(*namelist, **kargs):
    """Dump a list of variables by name"""
    
    val_pre=kargs.get('pre', '>')
    val_suf=kargs.get('suf', '<')
    val_sep=kargs.get('sep', ', ')
    g = kargs.get('globs', None)
    l = kargs.get('locs', None)
    
    format = ''
    sep = ''
    for name in namelist:
        if l and l.has_key(name):
            val = l[name]
        elif g and g.has_key(name):
            val = g[name]
        else:
            name = '?' + name + '?'
            val = '???'
        format = format + '%s%s%s%s%s' % (sep, name, val_pre, val, val_suf)
        sep = val_sep
    return format

###############################################################
def set_debug_leader(s):
    debug_leader = s

###############################################################
def set_debug_leader_sep(s):
    debug_leader_sep = s
    
###############################################################
def set_eprint_leader(s):
    eprint_leader = s
    
###############################################################
def set_print_leader(s):
    print_leader = s

###############################################################
def print_vars(*namelist, **kargs):
    print apply(dump_vars, namelist, kargs)


###############################################################
def bq(cmd):
    """Run a command, capturing stdout and stderr, mixed, into a string.
Returns that string.
Reads all output at once, so beware capturing huge outputs."""
    fds = os.popen4(cmd)
    ret = fds[1].read()
    fds[0].close()
    fds[1].close()
    return ret

if __name__ == "__main__":
    import sys
    argv = sys.argv[1:]
    while len(argv) >= 2:
        s = hilight_match(argv[0], argv[1])
        print '[%s], [%s], [%s]' % (argv[0], argv[1], s)
        argv = argv[2:]

    v1 = 'I am v1'
    v2 = 9999
    alist = [1,2,3]
    atuple = ('a', 'b', 'c')
    print_vars('v1', 'v2', 'undef1', 'alist', 'atuple', locs=locals(),
               globs=globals())

    printf("this printf should be seen\n");
    print_off()
    printf("this printf shouldn't be seen\n");

    eprintf("this eprintf should be seen\n");
    eprint_off()
    eprintf("this eprintf shouldn't be seen\n");

    debug("this debug shouldn't be seen\n");
    debug_on()
    debug("this debug should be seen\n");

    debug_file(('debug-test', 'a'), 1)
    debug('test 2 to debug-test\n')

    cdebug(0, '0: this cdebug should not be seen.\n')
    cdebug(-1, '-1: this cdebug should be seen.\n')

    debug_level = 0
    cdebug(0, '0: this cdebug should be seen.\n')

    
