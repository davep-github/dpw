#!/usr/bin/env python
# $Id: del_dups.py,v 1.1 2003/10/13 02:30:32 davep Exp $


import os, sys, string, stat, getopt, filecmp, re
import dp_io, dp_utils

opath = os.path                         # Fewer letters and lookups.

NO_RM_FILE = ".NO_RM_DUPS"

# @todo
CMD_TEMPLATE = "rm -f %s # %s"

#
Really_unlink = False
Symlink = False
# hashed by len, each is a list
length_dict = {}
dupes = []
zero_lens = []
no_rm_dirs = []


kb = 1024
mb = kb*kb
gb = mb*kb

victim_regexp = re.compile ("_copy_|[^a-zA-Z](bak|old|bad)([^a-zA-Z]|$)")

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

def no_rm_dupe_check (z_file, c_file):
    # If there's a NO_RM_DUPS file, then we only rm dupes in that dir, not
    # dupes from other directories.  ??? @todo : offer to rm & symlink???
    return (opath.dirname(z_file) in no_rm_dirs and
            opath.dirname(c_file) in no_rm_dirs and
            opath.dirname(z_file) == opath.dirname(c_file)):


########################################################################
def pick_victim (z_index, c_index, z_file, c_file, l):
    """Return (file-to-rm, file-to-say-same-as)."""
    # certain substrings imply higher deletability.
    # @todo things like -v1.zip, etc.
    if victim_regexp.search(c_file):
        # Nuke the c file...
        return z_file, c_file
    if victim_regexp.search(z_file):
        # Nuke the base comparison file
        # Put other file in its place.
        l[z_index], l[c_index] = l[c_index], l[z_index]
        return c_file, z_file
    
    # But otherwise, longer names are probably more specific.
    if (len(c_file) <= len(z_file)):
        # Nuke the c file...
        return z_file, c_file
    else:
        l[z_index], l[c_index] = l[c_index], l[z_index]
        return c_file, z_file

########################################################################
def process_length_dict(every_n=1000):
    dp_io.vprintf('\n')
    total_recovered = 0
    unlinkables = []
    total_n = 0
    rm_ticker = dp_utils.Ticker_t(every_n, printor=dp_io.vprintf)
    for l in length_dict.values():
        lenl = len(l)
        for z_index in range(0, lenl):
            z_file = l[z_index]
            if not z_file:
                continue
            if not opath.exists(z_file):
                continue
            for c_index in range(z_index+1, lenl):
                z_file = l[z_index]
                c_file = l[c_index]
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
                        print 'rm -f', rm_file, \
                              '# (%s%s) same as' % (file_size, suffix), \
                              same_as
                        if Really_unlink:
                            os.unlink(rm_file)
                        else:
                            unlinkables.append(rm_file)
                        # Leave the old name in place via a symlink.
                        if Symlink:
                            os.symlink(same_as, rm_file)
                            

    orig_total = total_recovered
    if Really_unlink:
        would_be = " was "
    else:
        would_be = " would be "
    total_recovered, suffix, divisor, p = human_readable(total_recovered)
    dp_io.printf("Space that%srecovered: %s%s%s (%d bytes)\n", would_be,
                 total_recovered, suffix, p, orig_total)
    if not Really_unlink and len(unlinkables):
        dp_io.printf("Want to unlink the files [y/N]? ")
        ans = sys.stdin.readline()
        if ans[-1] in "\n\r":
            ans = ans[:-1]
        ans = string.lower(ans)
        if ans in ["y", "yes"]:
            for f in unlinkables:
                if not opath.exists(f):
		    dp_io.eprintf("WARNING: %s vanished\n", f)
		else:
                    os.unlink(f)
            
########################################################################
def visit_dir(force_rm_p, dirname, fnames):
    dp_io.vprintf("d")
    dp_io.cdebug(1, ':visiting %s\n', dirname)
    if NO_RM_FILE in fnames and not force_rm_p:
        no_rm_dirs.append(dirname)
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
        else:
            if not length_dict.has_key(size):
                length_dict[size] = []
            length_dict[size].append(name)


if __name__ == "__main__":
    force_rm_p = False
    options, args = getopt.getopt(sys.argv[1:], 'dsRD:fS')
    for o, v in options:
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
        if o == '-R':
            Really_unlink = not Really_unlink
            continue
        if o == '-f':
            force_rm_p = not force_rm_p
            continue
        if o == '-S':
            Symlink = not Symlink
            continue
        
    if len(args) == 0:
        args = ["."]
    for dir in args:
        if opath.isdir(dir):
            opath.walk(dir,  visit_dir, force_rm_p)
        elif opath.isfile(dir):
            opath.walk(None,
                       opath.dirname(opath.opath.realpath(dir)),
                       [opath.basename(opath.opath.realpath(dir))])
        else:
            raise RuntimeError("%s neither dir nor file.", dir)
    process_length_dict()
