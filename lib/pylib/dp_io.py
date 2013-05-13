#!/usr/bin/env python
# $Id: dp_io.py,v 1.13 2005/06/15 22:45:16 davep Exp $
#
import re, types, os, sys, types, string, select, StringIO
import dp_sequences, dp_utils
Have_subprocess_module_p = False
try:
    import subprocess
    Have_subprocess_module_p = True
except ImportError:
    Have_subprocess_module_p = False

f_debug = False                         # turns on/off *ALL* debug prints
f_eprint = True                         # turns on/off *ALL* error prints
f_print = True                          # turns on/off *ALL* regular prints
f_vprint = False                        # turns on/off *ALL* verbose prints

lint = True                             # help clean up external usage

default_debug_files = [sys.stderr]      # where debugging prints go
default_eprint_files = [sys.stderr]     # where error prints go
default_tprint_files = [sys.stderr]     # where trace prints go
default_print_files = [sys.stdout]      # where regular prints go
default_vprint_files = [sys.stdout]     # where verbose prints go

v_debug_files = default_debug_files
v_eprint_files = default_eprint_files
v_tprint_files = default_tprint_files
v_print_files = default_print_files
v_vprint_files = default_vprint_files

all_files_lists = [v_debug_files, v_eprint_files, v_tprint_files,
                   v_print_files, v_print_files]

def purge_streams(streams, from_these=None):
    from_these = from_these or all_files_lists
    for flist in from_these:
        for s in streams:
            if s in flist:
                flist.remove(s)

DEF_DEBUG_LEADER = 'debug'
debug_leader = DEF_DEBUG_LEADER
debug_leader_sep = ': '
eprint_leader = ''
print_leader = ''
vprint_leader = ''
tprint_leader = '+'

debug_level = -1                        # for cdebug
debug_mask = 0                          # for fdebug
debug_keyword_list = []   # like mask, but with items in list vs bits in int.
debug_keyword_no_header = False # no header before message
debug_keyword_print_all = False # Print all regardless of keyword. Obey f_debug
verbose_level = -1                      # for vdebug
verbose_level_stack = []

def push_level(stack, gettor, new_level, settor):
    """Do pushing and setting of the new level here so we can more easily
become atomic if we have to."""
    old_level = gettor()
    stack.append(old_level)
    settor(new_level)
    return old_level

def pop_level(stack):
    new_level = stack.pop()
    return new_level

def verbose_push_level(new_level):
    return push_level(verbose_level_stack, get_verbose_level,
                      new_level, set_verbose_level)

def verbose_pop_level():
    return pop_level(verbose_level_stack)

osname = os.uname()[0]
BOLD = ""
SOUT = ""
NORM = ""

# Black list
DP_IO_NO_TERM_INIT_TERMS = ("emacs",)

# Better to have a white list and offer NO bolding, etc, by default?
# No bolding where it can be done is better than bunches of error messages
# where it can't be.
# Then again, we can just log the error elsewhere.
# But this seems to be a not insignificant time suck, especially since this
# gets done any time this module is loaded.  Python needs something like
# autoloading, where something special is done the first time some feature
# (with a defined set) is activated. So a run hook can be attached to the
# routines that actually use the BOLD, etc, stuff.
# ??? Put them in a special class and use special attribute access to do the
# init once when they are needed.
#Something like terminfo.BOLD is originally defined as self.v_BOLD =
#os.popen('tput md').read(); return self.v_BOLD but then is redefined to be
#return self.v_BOLD
# Could use memoizing, but changing func def is quicker to call in future.

if (os.environ.get('TERM')
    and
    (os.environ.get('TERM') not in DP_IO_NO_TERM_INIT_TERMS)
    and
    not os.environ.get("dp_io_no_term_init")):
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
def sprintf(fmt, *args):
    """sprintf - return formatted string.
    If no *args, just return fmt, otherwise apply args to fmt."""
    if args:
        fmt = fmt % args
    return fmt
    
###############################################################
def eprintf(fmt, *args):
    """eprintf - print to stderr or user specified error files."""
    if f_eprint:
        if args:
            fmt = fmt % args
        lprint(v_eprint_files, eprint_leader, fmt)

###############################################################
def printf(fmt, *args):
    if type(fmt) == types.IntType:
        if lint:
            warning = 'HEY, you left a level in a printf/PRINTF\n'
            sys.stderr.write(warning)
            sys.stdout.write(warning)
        fmt = args[0]
        args = args[1:]
    if f_print:
        if args:
            fmt = fmt % args
        lprint(v_print_files, print_leader, fmt)

# visible printf for easy location.  Used for very temporary prints.
PRINTF = printf

###############################################################
def fprintf(ofiles, fmt, *args):
    ofiles = dp_sequences.mktuple(ofiles)
    if f_print:
        if args:
            fmt = fmt % args
        lprint(ofiles, print_leader, fmt)

###############################################################
def do_debug(fmt, leader, args, **kw_args):
    if f_debug:
        if args:
            fmt = fmt % args
        lprint(v_debug_files, leader+debug_leader_sep, fmt)

def do_ldebug(level, fmt, leader, *args):
    if (debug_level >= level):
        do_debug(fmt, leader, *args)
    
###############################################################
def debug(fmt, *args, **kw_args):
    global debug_leader
    leader = kw_args.get("leader")
    set_leader_p = kw_args.get("set_leader_p")
    if  leader is None:
        leader = debug_leader
    elif set_leader_p:
        debug_leader = leader
        
    do_debug(fmt, leader, args)

dprintf = debug                         # alias
    
###############################################################
def cdebug(level, fmt, *args):
    '''conditional debug.
    print if debugging is on AND level >= debug_level'''
    #print "debug_level:", debug_level, "level:", level
    #print "debug_level >= level:", (debug_level >= level)
    # NB: True == 1, but 1 is not True
    if (debug_level >= level) or (level is True):
        print "WTF?!?!?!"
        do_debug(fmt, '%s[%02s]' % (debug_leader, level), args)

ldebug = cdebug                         # alias, level debug
ldprintf = cdebug
cdprintf = cdebug

###############################################################
def tracef (fmt, *args):
    '''Trace printf'''
    #cdebug (True, fmt, *args)
    if args:
        fmt = fmt % args
    lprint(v_tprint_files, tprint_leader, fmt)

tprintf = tracef

###############################################################
def debug_mask_exact_set(mask):
    return mask ==  debug_mask

def debug_mask_all_set(mask):
    return (mask & debug_mask) == mask

def debug_mask_any_set(mask):
    return mask & debug_mask
    

def fdebug(mask, fmt, *args):           # flag debug
    if debug_mask_any_set(mask):
        do_debug(fmt, '%s[0x%x]' % (debug_leader, mask), args)

mdebug = fdebug                         # alias, mask debug
        

###############################################################
# work better as a set vs a list?
#
def set_debug_keyword_list(keys):
    dp_sequences.extend_list(debug_keyword_list, keys)

def add_debug_keyword(keys):
    dp_sequences.extend_list(debug_keyword_list, keys)

def rm_debug_keyword(keys):
    dp_sequences.del_list_items(debug_keyword_list, keys)
   
def debug_keyword_all_set_p(keys, kw_list=None):
    if keys == True:
        return True
    keys = dp_sequences.mklist(keys)
    if not kw_list:
        kw_list = debug_keyword_list
    for k in keys:
        if k not in kw_list:
            return False
    return True

def debug_keyword_exact_set_p(keys):
    if keys == True:
        return True
    keys = dp_sequences.mklist(keys)
    # all in keys in the debug_keyword_list???
    if not debug_keyword_all_set_p(keys):
        return False
    # all in debug_keyword_list in keys???
    if not debug_keyword_all_set_p(debug_keyword_list, keys):
        return False
    

def debug_keyword_any_set_p(keys):
    #print 'keys>%s<' % keys
    #print 'debug_keyword_list>%s<' % debug_keyword_list
    if keys == True:
        return True
    
    keys = dp_sequences.mklist(keys)
    for k in keys:
        if k in debug_keyword_list:
            return True
    return False

def do_kwdebug(predicate, keys, fmt, args):
    if predicate(keys) or debug_keyword_print_all:
        if debug_keyword_no_header:
            hdr = ''
        else:
            hdr = '%s[keys:%s]' % (debug_leader, keys)
        #print 'f_debug:', f_debug
        do_debug(fmt, hdr, args)

def kwdebug(keys, fmt, *args):           # keyword debug
    do_kwdebug(debug_keyword_any_set_p, keys, fmt, args)

def kwalldebug(keys, fmt, *args):        # keyword debug
    do_kwdebug(debug_keyword_all_set_p, keys, fmt, args)

def kwexactdebug(keys, fmt, *args):      # keyword debug
    do_kwdebug(debug_keyword_exact_set_p, keys, fmt, args)

###############################################################
def debug_exec(level, func, *args, **keys):
    if f_debug and (debug_level >= level):
        func(*args, **keys)
        
###############################################################
def verbose_p(level):
    return f_vprint and (verbose_level >= level or level == True)
    
def vcprintf(level, fmt, *args):
    """vcprintf: Verbose, conditional printf.
    Print messages depending on verbosity level."""
    #print "vc:level>%s<, fmt>%s<, args>%s<" % (level, fmt, args)
    if verbose_p(level):
        if args:
            fmt = fmt % args
        lprint(v_vprint_files, vprint_leader, fmt)

###############################################################
def vprintf(fmt, *args):
    """vprintf: Unconditional printf on the verbosity channel."""
    #print 'f_vprint: %d, verbose_level: %d\n' % (f_vprint, verbose_level)
    #print "v:fmt>%s<, args>%s<" % (fmt, args)
    vcprintf(True, fmt, *args)

###############################################################
def set_debug(onoff=True):
    global f_debug
    f_debug = onoff

###############################################################
def debug_off():
    set_debug(False)

###############################################################
def debug_on():
    set_debug(True)

###############################################################
def get_debug_level():
    return debug_level

def set_debug_level(level, enable_debugging_p=False,
                    disable_debugging_p=False):
    global debug_level
    old_level = get_debug_level()
    debug_level = level
    if enable_debugging_p:
        debug_on()
    if disable_debugging_p:
        debug_off()
    return old_level

###############################################################
def inc_debug_level(delta=1, limit=None):
    global debug_level
    new_level = debug_level = delta
    if limit is None or new_level < limit:
        debug_level = new_level
    else:
        debug_level = limit
    return debug_level

###############################################################
def dec_debug_level(delta=1, floor=0):
    global debug_level
    if debug_level > floor:
        debug_level -= delta
    return debug_level

###############################################################
def set_debug_mask(mask):
    global debug_mask
    debug_mask = mask

###############################################################
def get_verbose_level():
    return verbose_level

def set_verbose_level(level):
    global verbose_level
    old_level = get_verbose_level()
    verbose_level = level
    return old_level
    #print 'verbose_level:', verbose_level, 'level:', level

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
def set_vprint(onoff=True):
    global f_vprint
    f_vprint = onoff

###############################################################
def YOPP():
    printf("YOPP!\n")

def eYOPP():
    eprintf("eYOPP!\n")

def eYOPPf(fmt, *args):
    if args:
        fmt = fmt % args
    lprint(v_eprint_files, 'eYOPPf: ', fmt)

def YOPPf(fmt, *args):
    if args:
        fmt = fmt % args
    lprint(v_print_files, 'YOPPf: ', fmt)
    
###############################################################
def vprint_off():
    set_vprint(0)

###############################################################
def vprint_on():
    set_vprint(1)

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
def set_ofiles(file, flist, append=False):
    """file can be a string == filename,
    a tuple (filename, open-mode) or
    an open file object.
    Append says to append the file to the list of files."""
    if not append:
        del flist[:]
    mode = 'w'
    fname = ''
    if (type(file) == types.TupleType):
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
    flist.extend(dp_sequences.listify(file))

###############################################################
def reset_ofiles(flist, def_files):
    del flist[:]
    flist.extend(def_files)

###############################################################
def debug_file(file, append=0):
    set_ofiles(file, v_debug_files, append)
    
def reset_debug_file():
    set_ofiles(v_debug_files, default_debug_files, append=False)
    
###############################################################
def eprint_file(file, append=0):
    set_ofiles(file, v_eprint_files, append)

def reset_eprint_file():
    set_ofiles(default_eprint_files, v_eprint_files, append=False)
    
###############################################################
def print_file(file, append=0):
    set_ofiles(file, v_print_files, append)
    
def reset_print_file():
    set_ofiles(default_print_files, v_print_files, append=False)

###############################################################
def tprint_file(file, append=0):
    set_ofiles(file, v_tprint_files, append)
    
def reset_tprint_file():
    set_ofiles(default_tprint_files, v_tprint_files, append=False)

###############################################################
def vprint_file(file, append=0):
    set_ofiles(file, v_vprint_files, append)
    
def reset_vprint_file():
    set_ofiles(default_vprint_files, v_vprint_files, append=False)

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
# Sigh. Compatibility.
# Just because if FOSS doesn't mean everyone can/will/has update[ed].
# The popen family was just fine. IMO, subprocess, in this context, adds
# nothing.
if Have_subprocess_module_p:
    def bq(cmd):
        """Run a command, capturing stdout and stderr, mixed, into a string.
        Returns that string. CMD is passed straight thru to Popen.  Reads all
        output at once, so beware capturing huge outputs."""
        p = subprocess.Popen(cmd, shell=True,
                             stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, close_fds=True)
        return p.stdout.read()          # Joined w/stderr.

    ###############################################################
    def bq_lines(cmd):
        """Run a command, capturing stdout and stderr, into 2 lists of
        strings.  Returns those lists.  Reads all output at once, so beware
        capturing huge outputs."""
        p = subprocess.Popen(cmd, shell=True,
                             stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, close_fds=True)
        ret = p.stdout.readlines()
        return ret
else:
    def bq(cmd):
        return os.popen(cmd).read()

    ###############################################################
    def bq_lines(cmd):
        return os.popen(cmd).readlines()

###############################################################
def bq_lines_blah(cmd):
    """Run a command, capturing stdout and stderr, into 2 lists of
    strings.
Returns those lists.
Reads all output at once, so beware capturing huge outputs."""
    try:
        out_ret = []
        err_ret = []
        fds = os.popen3(cmd)
        out_ret = fds[1].readlines()
        err_ret = fds[2].readlines()
        fds[0].close()
        fds[1].close()
        fds[2].close()
        return (out_ret, err_ret)
    except AttributeError:
        # looks like no popen4, fake it
        # combine 2 into 1 unless redirection for 2 is already specified.
        # the search for 2's redirection is very lame.
        if not re.search('2\s*>', cmd):
            cmd =  cmd + ' 2>&1'
        fd = os.popen(cmd)
        ret = fd.readlines()
        fd.close ()
        return ret

###############################################################
def file_length(f):
    opened = False
    if type(f) == types.StringType:
        f = open(f)
        opened = True
    f.seek(0, 2)
    ret = f.tell()
    if opened:
        f.close()
    return ret


########################################################################
def dump_array_of_lines_to_str(lines, msg='', prefix2='\n>',
                        postfix='<\n', separator='<\n>'):
    #YOPPf('in dump_array_of_lines(%s)\n', lines)
    if not lines:
        printf('%s empty\n', msg+prefix2)
        return
    
    return '%s%s%s' % (msg+prefix2, string.join(lines, separator), postfix)

def dump_array_of_lines(lines, msg='', prefix2='\n>',
                        postfix='<\n', separator='<\n>'):
    #YOPPf('in dump_array_of_lines(%s)\n', lines)
    if not lines:
        printf('%s empty\n%s', msg+prefix2, postfix)
        return
    
    printf('%s', dump_array_of_lines_to_str(lines, msg, prefix2,
                                            postfix, separator))
    
def dump_array_of_objects(lines, msg='', prefix2='\n>',
                          postfix='<\n', separator='<\n>'):
    #YOPPf('in dump_array_of_objects(%s, %s)\n', msg, lines)
    olines = []
    for l in lines:
        olines.append(`l`)
        
    dump_array_of_lines(olines, msg, prefix2, postfix, separator)

def func_printer(printer, fmt, *args, **keys):
    fmt = fmt % args
    fmt = fmt % keys
    depth = keys.get('depth', 3)
    loud = keys.get('loud', False)
    if loud:
        loud = "!!!"
    else:
        loud = ''
    printer('%s%s(): %s', loud, dp_utils.function_name(depth), fmt)

def func_printf(fmt, *args, **keys):
    func_printer(printf, fmt, *args, **keys)

def func_eprintf(fmt, *args, **keys):
    func_printer(eprintf, fmt, *args, **keys)

def write_me_warning(**keys):
    func_printer(eprintf, "WRITE ME!!!\n", **keys)
    if keys.get("panic", False):
        raise RuntimeError("Required function not written")

def func_sprintf(fmt, *args, **keys):
    fmt = fmt % args
    fmt = fmt % keys
    depth = keys.get('depth', 2)
    return '%s: %s' % (dp_utils.function_name(depth), fmt)

def poll_istream(istream=sys.stdin, sleep_time=0.1):
    (rlist, wlist, xlist) = select.select([istream], [], [], sleep_time)
    if rlist:
        ret = rlist[0].read(1)
    else:
        ret = None
    return ret

def do_sprintf_called_from(level, fmt, *args, **keys):
    fmt = fmt % args
    fmt = fmt % keys
    return '%s called from %s' % (fmt, dp_utils.function_name(level))

def sprintf_called_from(fmt, *args, **keys):
    return do_sprintf_called_from(4, fmt, *args, **keys)

def printf_called_from(fmt, *args):
    printf('%s\n', do_sprintf_called_from(4, fmt, *args))
    
########################################################################
def file_len(fil):
    stat = os.stat(fil.fileno())
    return stat.size

########################################################################
def sed_ish(regexp, replacement, file_names, ofile=None):
    '''Simple (regexp-->constant string) replacement. NO back references,
    e.g. \1, \2, etc.
    However, regex and replacement can be callable,
    so if YOU want to do it, feel free.
    '''
    rets = []
    if type(regexp) == types.StringType:
        regexp = re.compile(regexp)
    for fname in file_names:
        ret = []
        for line in open(fname, 'r'):
            if not line:
                break
            if callable(regexp):
                line = regexp(line, replacement)
            else:
                for m in re.finditer(regexp, line):
                    if callable(replacement):
                        line = replacement(line, regexp, m)
                    else:
                        line = line.replace(m.group(0), replacement)
            if not ofile:
                ret.append(line)
            else:
                ofile.write(line)
        if not ofile:
            rets.append(ret)
    if not ofile:
        return rets
    else:
        return None

#############################################################################
Print_func_to_files_map = {
    debug: v_debug_files,
    cdebug: v_debug_files,
    fdebug: v_debug_files,
    
    eprintf: v_eprint_files,
    eYOPP: v_eprint_files,
    eYOPPf: v_eprint_files,

    tprintf: v_tprint_files,

    YOPPf: v_print_files,
    YOPP: v_print_files,
}

def print_func_files(func):
    return Print_func_to_files_map.get(func)

def y_or_n_p(default='n', fmt="", *args):
    y, n = "y", "n"
    if default:
        if default in "yY":
            y = "Y"
        elif default in "nN":
            n = "N"
    yn = "(%s/%s)? " % (y, n)
        
    while True:
        dp_io.printf(fmt+yn, *args)
        ans = sys.stdin.readline()[:-1]
        if not ans and not default:
            # not default --> require an answer.
            
            continue
        # "" is always in a string.
        if ans in "yYnN":
            break
    if ans == '':
        ans = default
    return ans in "yY"

#############################################################################
#############################################################################
#############################################################################
#############################################################################
#############################################################################
#############################################################################
#############################################################################
#############################################################################
if __name__ == "__main__":              # <:main:>

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

    sys.stderr.write("""You shouldn't see any lines with ``shouldn't be seen'', except this one.\n""")
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

    #@todo add masked debug test
    debug_mask = 0
    fdebug(0xff, '0: this fdebug should not be seen.\n')

    debug_mask = 9
    fdebug(0x0, '0: this fdebug should not be seen.\n')

    fdebug(0x01, '1: this fdebug should be seen.\n')

    # bq
    exp='expr 7 \\* 100 + 7 \\* 10 + 7'
    s = bq(exp)
    print 'bq(%s) >%s<' % (exp, s)
