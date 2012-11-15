"""utils.py
Some helpful utility functions."""

import os, sys, string, stat, pprint, types, re

class DP_UTILS_RT_Exception(RuntimeError):
    def __init__(self, fmt, *args, **keys):
        self.init_fmt = fmt
        if args:
            fmt = fmt % args
        RuntimeError.__init__(self, fmt)
        self.init_args = args
        self.init_keys = keys


__NS__ = None
__GLOBALS__ = None
def utils_init(export_ns, global_ns):
    global __NS__
    global __GLOBALS__
    __NS__ = export_ns
    __GLOBALS__ = global_ns

def export(__indict__=None, **names):
    """Export names by placing their names in the builtin dictionary"""
    if __indict__:
        __NS__.__dict__.update(__indict__)
    __NS__.__dict__.update(names)

def export_module(mod):
    d = {}
    ns = dir(mod)
    for name in ns:
        if name[0] != '_':
            d[name] = mod.__dict__[name]
    export(d)


def run_shell_cmd(cmd, quiet=None, stdout_too=1):
    """run_shell_cmd(cmd, quiet=None, stdout_too=1)
Run the command cmd via popen.
stdout_too says to redirect stdout into the pipe also"""
    if stdout_too and string.find(cmd, '2>&1') < 0:
        #cmd = '{' + cmd + '; } 2>&1'
        cmd = cmd + ' 2>&1'
    #print 'cmd', cmd
    proc = os.popen(cmd)
    while 1:
        line = proc.read(1)
        if not line:
            break
        if not quiet:
            b._echo(line)
    return proc.close()


def sh(line=None):
    """sh(line=None)
Run shell or cmd in shell"""
    if not line:
        line = os.environ.get('SHELL')
        if not line:
            line = '/bin/sh'
        print 'Running shell:', line
    return os.system(line)


def sh2(cmd, *args):
    """sh2(cmd, *args)
debugging func"""
    if os.fork() == 0:
        print 'in child, cmd:', cmd
        os.execvp(cmd, (cmd, ) + args)
    else:
        print 'parent waiting'
        s = os.wait()
        print 'parent done'
        print '0x%x, 0x%x' % (s[0], s[1])
        return s


__Last_rc_args__ = None
def source(*args):
    """source(*args)
Execute a python script or scripts in the global namespace.
No args says to used the last set of args"""
    global __Last_rc_args__
    if not args:
        args = __Last_rc_args__
    for file in args:
        try:
            execfile(os.path.expanduser(file), __GLOBALS__)
        except IOError:
            eprint('source: Cannot open>%s<\n', file)
    __Last_rc_args__ = args


def str_proc_stat(status):
    """str_proc_stat(status)
Convert popen() close status to string"""
    if status & 0x8000:
        status = status >> 8
    if os.WIFSTOPPED(status):
        s1 = 'STOPPED'
        s2 = os.WSTOPSIG(status)
    elif os.WIFSIGNALED(status):
        s1 = 'SIGNALED'
        s2 = os.WTERMSIG(status)
    elif os.WIFEXITED(status):
        s1 = 'EXITED'
        s2 = os.strerror(os.WEXITSTATUS(status))
    else:
        s1 = status & 0x00ff
        s2 = (status >> 8) & 0x00ff

    return '%s:%s' % (s1, s2)


########################################################################
#
# find an rc file.
# If no path is provided, construct one.  Look for an envvar that is
# an uppercase, no leading dot version of the rc file.
# Look there, in the cwd and in the home dir.
#
########################################################################
def locate_rc_file(name, path=None):
    if path == None:
        path = []
        evar = string.upper(name)
        if evar[0] == '.':
            evar = evar[1:]
        evalue = os.environ.get(evar)
        if evalue:
            path.append(evalue)
        path = path + [os.getcwd(), os.environ.get('HOME')]

    for place in path:
        if path[-1] == '/':
            sep = ''
        else:
            sep = '/'
        place = place + sep + name
        try:
            os.stat(place)
            return place
        except OSError:
            pass


#
# convert a number to 0 padded binary
#
def cbin(val, width=0):
    """cbin(val, width=0)
Convert val to a binary string.  Pad to width bits if specified."""
    s = ''
    while val:
        if val & 1:
            s = '1' + s
        else:
            s = '0' + s
        val = val >> 1
        val &= ~0x80000000

    while len(s) < width:
        s = '0' + s

    return s


def pbin(val, width=0):
    """pbin(val, width=0)
Print the binary string of val after calling cbin(q.v.)"""
    print cbin(val, width)


def cbinh(val, width=0):
    """cbinh(val, width=0)
Convert val to binary as per cbin.  Add a bit index header for easy viewing."""
    s = cbin(val, width)
    l = len(s)
    th = ''
    bh = ''
    for b in xrange(l, 0, -1):
        b = b - 1
        q, r = divmod(b, 10)
        th = '%s%s' % (th, q)
        bh = '%s%s' % (bh, r)
    uline = '-' * l
    return (th, bh, uline, s)

def pbinh(val, width=0):
    """print a cbinh string"""
    print string.join(cbinh(val, width), '\n')

def file_len(file):
    stat_buf = os.stat(file)
    return stat_buf[stat.ST_SIZE]

def bq(cmd):
    """bq(cmd) : backquote cmd as in the shell's `cmd`.
    Return the output as a string."""
    #fds = os.popen4(cmd)
    #ret = fds[1].read()
    #fds[0].close()
    #fds[1].close()
    return os.popen(cmd).read()

def repr_dict(id, od):
    '''Convert a dict to a dict containing reprs of each element.'''
    if od:
        od.clear()
    else:
        od = {}

    for k in id.keys():
        od[k] = `id[k]`
    return od

#
# called from a file tree walk
#
def find_leaf_dirs_func(data, dirname, fnames):
    cwd, leaf_dirs = data

    ##print 'dirname>%s<' % dirname
    dirname = os.path.join(cwd, dirname)
    dirname = string.replace(dirname, '/./', '/')
    ##print 'dirname>%s<' % dirname

    ###print "  ", string.join(fnames, "\n  ")
    for f in fnames:
        f = os.path.join(dirname, f)
        ##print "checking>%s<, dirness>%s<" % (f, os.path.isdir(f))
        if os.path.isdir(f):
            return                      # not a leaf, it contains a dir
    leaf_dirs.append(dirname)

def find_leaf_dirs(root):
    leaves = []
    if root[0] != '/':
        cwd = os.path.realpath('.')
    else:
        cwd = ''
    os.path.walk(dir, find_leaf_dirs, (cwd, leaves))

    return leaves

def function_name(levels=1):
    '''Version specific?????'''
    return sys._getframe(levels).f_code.co_name

def py_lineno(levels=1):
    return sys._getframe(levels).f_lineno

# I couldn't find something like this anywhere, but I'm sure it exists.
def find_file_in_path(filename, path=sys.path):
    ospath = os.path
    for dir in path:
        if dir in ['', ' ']:
            dir = '.'
        tname = ospath.join(dir, filename)
        if ospath.exists(tname):
            return tname
    return None

def prune_dict(d):
    #pprint.pprint(d)
    for k, v in d.items():
        if not v:
            del d[k]
        elif isinstance(v, dict):
            prune_dict(v)
            if not v:
                del d[k]
    return d

def system (command, msg=True, exit_p=True, exit_code=1, debug_p=False,
            pretend_p=False, pre_cmd_cmd=None):
    """if msg is True, then make a simple, default message using command name."""
    if (debug):
        if (command[-1] not in "\n\r"):
            command = command + "\n"
        dp_io.printf ("-n: %s", command )
        return 0
    else:
        try:
            if pre_cmd_cmd:
                system (pre_cmd_cmd)
            if pretend_p:
                dp_io.tprintf (command)
                ret = 0
            else:
                ret = os.system (command)
            return ret
        except Exception, e:
            if msg is True:
                msg = 'error running "%s".\n' % cmd
            if msg:
                if (msg[-1] not in "\n\r"):
                    msg = msg + "\n"
                dp_io.fprintf (msg)
            dp_io.fprintf (" exception info: %s" % e)
            if (exit_p):
                sys.exit (exit_code)
    # No matter how we got here, it's baaaad.
    return False


def nWithUnits(s):
    m = re.search("^(\d+(\.\d+)?)\s*([kKmMgGtT]?)$", s)
    if not m:
        print >>sys.stderr, "Warning: sizeWithUnits: no match."
        return 0                   # Or should it be an error with no digits?
    n = eval(m.group(1))
    suffix = m.group(3)
    if suffix:
        suffix = suffix.lower()
        exp = {'k': 1, 'm': 2, 'g': 3, 't': 4}[suffix]
    else:
        exp = 0
    mult = math.pow(1024, exp)
    val = n * mult
    if int(n) == n:
        val = int(val)
    return val
numWithUnits = nWithUnits

import string, os, sys, re, math

def nPlusUnits(n, allow_fractions_p=False):
     exp = 0
     if (allow_fractions_p):
          n = float(n)
     while (n >= 1024) and (allow_fractions_p or ((n % 1024) == 0)):
          n = n / 1024
          exp = exp + 1
     suffix = ("", "K", "M", "G", "T")[exp]
     return "%s%s" % (n, suffix)
numPlusUnits = nPlusUnits

def pluralize(name, num, singular="", plural="s"):
    if num == 1:
        suffix = singular
    else:
        suffix = plural
    return name + suffix
