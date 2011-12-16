#!/usr/bin/env python
# $Id: del_dups.py,v 1.1 2003/10/13 02:30:32 davep Exp $


import os, sys, string, stat, getopt, filecmp, re
import dp_io, dp_utils

opath = os.path                         # Fewer letters and lookups.

NO_RM_FILE = ".NO_RM_DUPS"

# @todo
CMD_TEMPLATE = "rm -f %s # %s"

#

kb = 1024
mb = kb*kb
gb = mb*kb

# hashed by len, each is a list
length_dict = {}
dupes = []
zero_lens = []

victim_regexp_string = "_copy_|[^a-zA-Z](bak|old|bad)([^a-zA-Z]|$)"
victim_regexp = re.compile (victim_regexp_string)

dp_io.set_debug(onoff=False)
dp_io.set_vprint(onoff=True)

########################################################################
def human_readable(n):
    for sz, sx, punct in ((gb, "G", "!!"), (mb, "M", "!"), (kb, "K", ""),
                          (1, "", ""), (0, "None", "")):
        if n >= sz:
            divisor = sz
            suffix = sx
            break
    if divisor:
        n /= divisor
    else:
        n = ''
    return (n, suffix, divisor, punct)

########################################################################
def pick_victim (z_index, c_index, z_file, c_file, l):
    """Return (file-to-rm, file-to-say-same-as)."""
    # certain substrings imply higher deletability.
    # @todo things like -v1.zip, etc.
    # return tuple(file, file-to-rm)
    
    while True:                         # So we can bail w/a break
        if victim_regexp.search(c_file):
            #print >>sys.stderr, "1"
            # Nuke the c file...
            return z_file, c_file
        if victim_regexp.search(z_file):
            # Nuke the base comparison file
            # Put other file in its place.
            #print >>sys.stderr, "1r"
            break
        # Longer paths are probably newer acquisitions, say, in a temp dir.
        c_base, z_base = opath.basename(c_file), opath.basename(z_file)
        if c_base == z_base:
            #print >>sys.stderr, "c>%s<" % c_file
            #print >>sys.stderr, "sc>%s<" % (c_file.split(opath.sep),)
            #print >>sys.stderr, "z>%s<" % z_file
            #print >>sys.stderr, "sz>%s<" % (z_file.split(opath.sep),)
            if len(c_file.split(opath.sep)) > len(z_file.split(opath.sep)):
                return z_file, c_file
            else:
                #print >>sys.stderr, "2r"
                break
        # But otherwise, longer file names are probably more specific.
        # e.g. dp-xxx is more specific than xxx
        if len(c_base) <= len(z_base):
            # Nuke the c file...
            #print >>sys.stderr, "3"
            return z_file, c_file
        break                           # Only one lap, regardless.
    #print >>sys.stderr, "def"
    l[z_index], l[c_index] = l[c_index], l[z_index]
    return c_file, z_file

########################################################################
def do_unlink(rm_file, same_as):
    if not opath.exists(rm_file):
        dp_io.eprintf("WARNING: %s vanished\n", rm_file)
    else:
        try:
            os.unlink(rm_file)
        except OSError, e:
            dp_io.eprintf("WARNING: OSError(unlink): %s\n", e)
        if same_as:
            # Leave the old name in place via a symlink.
            try:
                os.symlink(same_as, rm_file)
            except OSError, e:
                dp_io.eprintf("WARNING: OSError(symlink): %s\n", e)

########################################################################
def process_length_dict(every_n=1000, batch_unlink=True, symlink_p=False):
    dp_io.vprintf('\n')
    total_recovered = 0
    unlinkables = {}
    total_n = 0
    rm_ticker = dp_utils.Ticker_t(every_n, printor=dp_io.vprintf)
    pan_total = 0
    for l in length_dict.values():
        pan_total += len(l)
    print "pan_total: ", pan_total
    for l in length_dict.values():
        lenl = len(l)                   # List of files of the same size
        for z_index in range(0, lenl):
            z_file = l[z_index]
            if not z_file:
                continue
            if not opath.exists(z_file):
                continue
            for c_index in range(z_index+1, lenl):
                z_file = l[z_index]     # "base" file
                c_file = l[c_index]     # "compare" file
                dp_io.cdebug(3, 'check >%s< and >%s<\n', z_file, c_file)
                if z_file and c_file:
                    try:
                        if opath.samefile(z_file, c_file):
                            continue
                    except OSError, x:
                        # The file has most likely disappeared.
                        continue
                    #cmp_cmd = 'cmp %s %s' % (z_file, c_file)
                    #dp_io.cdebug(2, '%s\n', cmp_cmd)
                    #eq = not dp_io.bq(cmp_cmd)
                    rm_ticker()
                    cmp_cmd = 'filecmp.cmp(%s, %s, shallow=0)' % (z_file,
                                                                  c_file)
                    eq = filecmp.cmp(z_file, c_file, shallow=0)
                    if eq:
                        dp_io.cdebug(3, 'cmd: %s\n', cmp_cmd)
                        z_file, c_file = pick_victim (z_index, c_index,
                                                      z_file, c_file, l)
                        same_as, rm_file = z_file, c_file
                        file_size = os.stat(rm_file)[stat.ST_SIZE]
                        total_recovered += file_size
                        file_size, suffix, x, p = human_readable(file_size)
                        tf, ts, x, p = human_readable(total_recovered)
                        # ../pg # (75K/tot) same as ../pg2
                        fsz = "%s%s" % (file_size, suffix)
                        tfsz = "%s%s" % (tf, ts)
                        if batch_unlink:
                            print 'deferring: rm -f', rm_file, \
                                  '# (%s/%s) same as' % (fsz, tfsz), \
                                  same_as
                        if not batch_unlink:
                            do_unlink(rm_file, symlink_p and same_as)
                        else:
                            unlinkables[(rm_file, symlink_p and same_as)] = 1

    orig_total = total_recovered
    if not batch_unlink:
        would_be = " was "
    else:
        would_be = " would be "
    total_recovered, suffix, divisor, p = human_readable(total_recovered)
    dp_io.printf("\nSpace that%srecovered: %s%s%s (%d bytes)\n", would_be,
                 total_recovered, suffix, p, orig_total)
    
    if batch_unlink and len(unlinkables):
        dp_io.printf("Want to unlink the files [Y/n]? ")
        ans = sys.stdin.readline()
        if ans[-1] in "\n\r":
            ans = ans[:-1]
        if string.lower(ans) in ["y", "yes", ""]:
            for f in unlinkables.keys():
                do_unlink(f[0], symlink_p and f[1])
            
########################################################################
def visit_dir(force_rm_p, dirname, fnames):
    dp_io.vprintf("d")
    dp_io.cdebug(1, ':visiting %s\n', dirname)
    if NO_RM_FILE in fnames and not force_rm_p:
        return
    for name in fnames:
        # New: using realpath; check for errors.
        name = opath.realpath(opath.join(dirname, name))
        dp_io.cdebug(3, 'name>%s<\n', name)
        try:
            stat_buf = os.lstat(name)
        except:
            continue
        smode = stat_buf[stat.ST_MODE]
        dp_io.cdebug(4, 'smode: 0x%08x\n', smode)
        dp_io.cdebug(4, 'fmt: 0x%x, lnk: 0x%x\n', stat.S_IFMT(smode),
                     stat.S_IFLNK)
        if stat.S_ISDIR(smode):
            dp_io.cdebug(3, 'skipping dir\n')
            continue
        if stat.S_ISLNK(smode):
            dp_io.cdebug(3, 'skipping symlink\n')
            continue
        size = stat_buf[stat.ST_SIZE]
        if size == 0:
            dp_io.cdebug(3, 'queuing 0 len\n')
            zero_lens.append(name)
        elif size >= min_length:
            if not length_dict.has_key(size):
                length_dict[size] = []
            length_dict[size].append(name)


if __name__ == "__main__":
    min_length = 5 * kb
    force_rm_p = False
    batch_unlink = True
    symlink_p = False
    every_n = 1000
    options, args = getopt.getopt(sys.argv[1:], 'dsD:fSvbm:n:')
    for o, v in options:
        if o == '-n':
            every_n = eval(v)
            continue
        if o == '-m':
            global min_length
            min_length = eval(v)
            continue
        if o == '-d':
            dp_io.debug_on()
            dp_io.inc_debug_level()
            continue
        if o == '-D':
            dp_io.debug_on()
            dp_io.set_debug_level(eval(v))
            continue
        if o == '-s':
            dp_io.debug_on()
            dp_io.dec_debug_level()
            continue
        if o == '-b':
            batch_unlink = not batch_unlink
            continue
        if o == '-f':
            force_rm_p = not force_rm_p
            continue
        if o == '-S':
            symlink_p = not symlink_p
            continue
        if o == '-v':
            victim_regexp = re.compile("(" + victim +  ")" + "(" + v + ")")
                                       
        
    if len(args) == 0:
        args = ["."]
    for dir in args:
        if opath.isdir(dir):
            opath.walk(dir,  visit_dir, force_rm_p)
        elif opath.isfile(dir):
            visit_dir(force_rm_p=force_rm_p,
                      dirname=opath.dirname(opath.realpath(dir)),
                      fnames=(opath.basename(opath.realpath(dir)), ))
        else:
            raise RuntimeError("%s neither dir nor file.", dir)
    process_length_dict(every_n=every_n, batch_unlink=batch_unlink,
                        symlink_p=symlink_p)
