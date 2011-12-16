#!/usr/bin/env python
# $Id: del_dups.py,v 1.1 2003/10/13 02:30:32 davep Exp $


import os, sys, string, stat, getopt
import dp_io

#
Really_unlink = False
# hashed by len, each is a list
length_dict = {}
dupes = []
zero_lens = []

########################################################################
def process_length_dict():
    for l in length_dict.values():
        lenl = len(l)
        for z_index in range(0, lenl):
            z_file = l[z_index]
            if not z_file:
                continue
            for c_index in range(z_index+1, lenl):
                c_file = l[c_index]
                dp_io.cdebug(3, 'check >%s< and >%s<\n', z_file, c_file)
                if z_file and c_file:
                    cmp_cmd = 'cmp %s %s' % (z_file, c_file)
                    dp_io.cdebug(2, '%s\n', cmp_cmd)
                    not_eq = dp_io.bq(cmp_cmd)
                    if os.path.samefile(z_file, c_file):
                        continue
                    if not not_eq:
                        dp_io.cdebug(1, 'cmd: %s\n', cmp_cmd)
                        if l[z_index] and (len(z_file) < len(c_file)):
                            rm_file = c_file
                            same_as = z_file
                            l[z_index] = None
                        else:
                            rm_file = z_file
                            same_as = c_file
                            l[z_index] = None
                        print 'rm -f', rm_file, '# same as', same_as
                        if Really_unlink:
                            os.unlink(rm_file)

                    
            
            
########################################################################
def visit_dir(arg, dirname, fnames):
    dp_io.cdebug(3, 'visiting %s\n', dirname)
    for name in fnames:
        # New: using realpath; check for errors.
        name = os.path.realpath(os.path.join(dirname, name))
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
    options, args = getopt.getopt(sys.argv[1:], 'dsRD:')
    for o, v in options:
        if o == '-d':
            dp_io.debug_on()
            dp_io.inc_debug_level()
            continue
        if o == '-D':
            dp_io.debug_on()
            dp_io.set_debug_level(v)
            continue
        if o == '-s':
            dp_io.debug_on()
            dp_io.dec_debug_level()
            continue
        if o == '-R':
            Really_unlink = True
            continue

    if len(args) == 0:
        args = ["."]
    for dir in args:
        os.path.walk(dir,  visit_dir, None)
        process_length_dict()
