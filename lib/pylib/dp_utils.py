"""utils.py
Some helpful utility functions."""

import os, sys, string, stat, pprint, types, re, math
opath = os.path

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
def cbin(val, sep=False, sep_str=" ", width=8):
    """cbin(val, width=0)
Convert val to a binary string.  Pad to width bits if specified."""
    s = ''
    num_bits = 0
    if width and not sep:
        sep = True
    if (type(sep) == types.IntType) and sep != 1:
        width = sep

    while val:
        if sep and num_bits and ((num_bits % width) == 0):
            s = sep_str + s
        if val & 1:
            s = '1' + s
        else:
            s = '0' + s
        val = val >> 1
        val &= ~0x80000000
        num_bits += 1

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

def bq(cmd, hack_newline=True):
    """bq(cmd) : backquote cmd as in the shell's `cmd`.
    Return the output as a string."""
    #fds = os.popen4(cmd)
    #ret = fds[1].read()
    #fds[0].close()
    #fds[1].close()
    ret = os.popen(cmd).read()
    if hack_newline:
        ret = ret[:-1]
    return ret

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


def nWithUnits(s, allow_fractions_p=False, powers_of_two_p=True, base=None):
    if base is None:
         if powers_of_two_p:
             base = 1024
         else:
             base = 1000
    s = "%s" % (s,)
    m = re.search("^(\d+(\.\d+)?)\s*([kKmMgGtT]?)$", s)
    if not m:
        print >>sys.stderr, "Warning: numWithUnits: no match for>%s<." % (s,)
        return 0                   # Or should it be an error with no digits?
    n = float(eval(m.group(1)))
    if not allow_fractions_p:
        n = int(n)
    suffix = m.group(3)
    if suffix:
        suffix = suffix.lower()
        exp = {'k': 1, 'm': 2, 'g': 3, 't': 4}[suffix]
    else:
        exp = 0
    mult = math.pow(base, exp)
    val = n * mult
    if not allow_fractions_p:
        val = int(val)
    return val
numWithUnits = nWithUnits

import string, os, sys, re, math

def nPlusUnits(n, allow_fractions_p=False, powers_of_two_p=True, base=None):
    if n == 0:
        return "0"
    exp = 0
    if base is None:
        if powers_of_two_p:
            base = 1024
        else:
            base = 1000
    n = int(n)
    if (allow_fractions_p):
         n = float(n)
#    while (n >= base) and (allow_fractions_p or ((n % base) == 0)):
#         n = n / base
#         exp = exp + 1
    exp = math.log(n) / math.log(base)
    exp = int(exp)
    n = n / math.pow(base, exp)
    if not allow_fractions_p:
        n = int(n)
    suffix = ("", "K", "M", "G", "T")[exp]
    return "%s%s" % (n, suffix)
numPlusUnits = nPlusUnits

#######################################################################
##
## @brief Prevent things like "You have 1 messages" or "... 1 message(s)"
## 
def pluralize(name, num, singular="", plural="s"):
    if num == 1:
        suffix = singular
    else:
        suffix = plural
    return name + suffix

#######################################################################
##
## @brief Make the values of indict, keys in outdict.
## 
def invert_dict(indict):
    outdict = {}
    for k, v in indict.items():
        vals = outdict.get(v, [])
        vals.append(k)
        outdict[v] = vals

    for k, v in out_dict:
        print "k:", h, "vals:", v

#######################################################################
##
## @brief Return re compile flags to support the case matching convention.
## All lowercase --> case insensitive match.
## Any uppercase --> case sensitive match
##
def re_case_convention_flags(regexp_string):
    flags=0
    if regexp_string.islower():
        flags = re.IGNORECASE
    return flags

#######################################################################
##
## @brief Compile a regexp following the case convention.
## All lowercase --> case insensitive match.
## Any uppercase --> case sensitive match
##
## Allow flags to be specified to simplify calling code. It prevents the need
## for the "if flags is None" everywhere.
## 
def re_compile_with_case_convention(regexp_string, flags=None):
    if flags is None:
        flags = re_case_convention_flags(regexp_string)
    return re.compile(regexp_string, flags)

def make_db_file_name(name):
    return opath.join(os.environ["HOME"], "var", "db", name)

def newest_file(files):
    newest_mod_time = 0
    newest_file = None
    newest_index = -1
    for f in files:
        newest_index += 1
        if not opath.exists(f):
            continue
        mt = opath.getmtime(f)
        if mt > newest_mod_time:
            newest_mod_time = mt
            newest_file = f
        
    return newest_file, newest_mod_time, newest_index

def pathcomponents(path):
    p = opath.normpath(path)
    p = p.split(opath.sep)
    return p

def dir_existence(path):
    return opath.exists(path), opath.isdir(path)

def existing_dir(path):
    dx = dir_existence(path)
    return dx[0] and dx[1]

def mkpath(path):
    if existing_dir(path) or path == opath.sep:
        return True
    #path, dir = opath.split(path)
    components = pathcomponents(path)
    #print >>sys.stderr, "components>{}<".format(components)
    p = ''
    sep = ''
    for c in components:
        #print >>sys.stderr, "c>{}<".format(c)
        if c == '':
	    #print >>sys.stderr, "c was ''"
            p = '/'
            continue
        p = p + sep + c
        #print >>sys.stderr, "p>{}<".format(p)
        if not opath.exists(p):
            #print >>sys.stderr, "mkdir({})".format(p)
            os.mkdir(p)
        elif not opath.isdir(p):
            os.mkdir(p)                 # Raise the appropriate error.
        sep = opath.sep
            

#####################################################################
def process_gopath(args=None):
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
        names.extend(args)
    if not files:
        if os.environ.get('GOPATH'):
            files = string.split(os.environ.get('GOPATH'), ':')
        else:
            # Default fall back.
            files = [os.environ.get('HOME') + '/.go']
    xfiles = []
    for f in files:
        if opath.exists(f):
            xfiles.append(f)
    if not xfiles:
        print >>sys.stderr, "No go files. Exiting."
        sys.exit(1)
    xfiles.reverse()
    return xfiles, names

def cheesy_memoized_file(
    memo_file,
    dependencies,
    creator=None,
    eval_p=True,
    write_new_p=True,
    creator_args=None):
    contents = None
    newest, _, _ = newest_file(dependencies + [memo_file])
    if newest == memo_file:
        #print >>sys.stderr, "YAY! using memo file!"
        contents = open(memo_file, 'r').read()
    elif creator:
        #print >>sys.stderr, "meh. Creating memo data"
        contents = creator(memo_file, dependencies, creator_args)
        if contents and write_new_p:
            #print >>sys.stderr, "Sigh. writing memo data"
            ## @todo XXX May want to make this more sophisticated, say using
            ## more capable serialization/de-serialization methods.
            contents = repr(contents)
            open(memo_file, 'w').write(contents)

    #print >>sys.stderr, "contents>{}<".format(contents)
    if contents and eval_p:
        ## @todo XXX May want to make this more sophisticated, say using
        ## more capable serialization/de-serialization methods.
        return eval(contents)
    else:
        return contents

def dump_dp_vars(obj, pat="^d_", trailer="=================\n",
                 ostream=sys.stderr):
    for attr in dir(obj):
        m = re.search(pat, attr)
        if m:
            ostream.write("{}: {}\n".format(attr,
                                            obj.__getattribute__(attr)))
    if trailer:
        ostream.write("{}".format(trailer))
        

########################################################################
##
## Moved here from dp_misc.py which is being deprecated.
##
##

def dotdot_ify_url(url, num_dotdots=0, dotdot_string="", debug=False):
    if not num_dotdots:
        if dotdot_string:
            num_dotdots = len(string.split(os.path.normpath(".."), opath.sep))
    proto, path = urllib.splittype(url)
    host, path = urllib.splithost(path)
    path = os.path.normpath(path)
    path_elements = string.split(path, opath.sep)
    if debug:
        print >>sys.stderr, "path_elements:", path_elements
        print >>sys.stderr, "host:", host
    if num_dotdots:
        path_elements = path_elements[:0-num_dotdots]
    return "%s://%s%s" % (proto, host,
                           string.join(path_elements, opath.sep))

def identity(x):
    return x

def all_substrings(s, first=0, last=None, string_pp=identity):
    return [ s[first:i+1] for i in xrange(first, last or len(s)) ]

def any_substring(a, s, first=0, last=None, string_pp=string.lower):
    if string_pp == None:
        string_pp = identity
    return string_pp(a) in all_substrings(string_pp(s), first, last)

def normpath_plus(path, plus=opath.sep):
    return opath.normpath(path) + plus

def mkpath0(split_path):
    ppart = split_path[0]
    dpart = split_path[1]
    if os.exists(ppart) and opath.isdir(ppart):
        os.mkdir(ppart + opath.sep + dpart)
        return
    mkpath0(opath.split(dpart))

#def mkpath(path_string_or_list):
    #print >>sys.stderr, "path_string_or_list>{}<".format(path_string_or_list)
    #if type(path_string_or_list) == types.StringType:
        #npath = opath.normpath(path_string_or_list)
        #print >>sys.stderr, "npath>{}<".format(npath)
        #elements = npath.split(opath.sep)
    #else:
        #elements = path_string_or_list
    #print >>sys.stderr, "elements>{}<".format(elements)
    #p = elements[0]
    #elements = elements[1:]
    #for element in elements:
        #print >>sys.stderr, "element>{}<".format(element)
        #print >>sys.stderr, "p>{}<".format(p)
        #if opath.exists(p) and opath.isdir(p):
            #pass
        #else:
            ## If p is a file, we'll raise an appropriate error.
            #os.mkdir(p)
        #p = p + opath.sep + element

########################################################################
class Nop_t(object):
    def __init__(self):
        pass
    def __call__(self, *args, **keywords):
        return None

########################################################################
#
# Some simple network translations.
#

def dotted_to_bin(dotted_str, dot="."):
    """xxx.xxx.xxx.xxx to uint32"""
    xs = dotted_str.split(dot)
    num_octets = len(xs)
    if num_octets != 4:
        dp_io.eprintf("Wrong number of octets (%d) in>%s<\n",
                      num_octets, dotted_str)
        return None
    uint32 = 0
    octet_num = 3
    for x in xs:
        try:
            if x[0] in "0123456789":
                n = eval(x)
        except ValueError, e:
            dp_io.eprintf("Bad octet>%s<\n", x)
            return None
            
        uint32 = uint32 * 256
        if (n < 0) or (n > 255):
            dp_io.eprintf("octet %d is bad>%s<\n", octet_num, x)
            return None
        uint32 += n
        octet_num -= 1
    return uint32

def dotted_to_bits(dotted_str, sep=False, sep_str=" ", width=8, dot="."):
    uint32 = dotted_to_bin(dotted_str, dot=dot)
    if uint32 is None:
        return None
    return cbin(uint32, sep=sep, sep_str=sep_str, width=width)

def bin_to_dotted(uint32, dot):
    """32 bit unsigned integet to dotted notation."""
    parts = []
    for i in (0, 1, 2, 3):
        part = uint32 & 0xff
        parts.insert(0, str(part))
        uint32 = uint32 >> 8
    return dot.join(parts)

########################################################################
if __name__ == "__main__":
    for a in sys.argv[1:]:
        print "a>{}<".format(a)
        mkpath(a)

