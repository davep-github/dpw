#!/usr/bin/env python

import sys, os, re
opath = os.path

import portage, string
portage_versions = portage.versions

def get_pkg_names(file_name):
    ## eg:
    ## /var/db/pkg/sys-kernel/config-kernel-0.3.3
    ## or
    ## /var/db/pkg/sys-kernel/config-kernel-0.3.3/CONTENTS
    ## or
    ## config-kernel-0.3.3
    #print "file_name:", file_name
    file_comps = string.split(file_name, opath.sep)
    #print "file_comps:", file_comps, "file_comps[-1]:", file_comps[-1]
    #print "file_comps:", file_comps, "file_comps[-2]:", file_comps[-2]


    #print "file_comps:", file_comps, "file_comps[-1]:", file_comps[-1]
    if file_comps[-1] == "CONTENTS":
        #print "OK"
        full_pkg_name = file_comps[-2]
    else:
        #print "WTF?!"
        full_pkg_name = file_comps[-1]

    ## /var/db/pkg/sys-kernel/config-kernel-0.3.3
    ## /var/db/pkg/sys-kernel/config-kernel 0.3.3 r0
    pkg_bits = portage_versions.pkgsplit(full_pkg_name)
    #print "full_pkg_name:", full_pkg_name
    #print "pkg_bits:", pkg_bits
    short_pkg_name = pkg_bits[0]
    return full_pkg_name, short_pkg_name


def generate_commands(file_name):
    full_pkg_name, short_pkg_name = get_pkg_names(file_name)
    return ("emerge -C =%s || echo 1>&2 failed to emerge -C %s" %
            (full_pkg_name, full_pkg_name),
            "emerge  %s || echo 1>&2 failed to emerge %s" % (short_pkg_name,
                                                             short_pkg_name))


def generate_all_commands(argv):
    ret = []
    if len(argv) == 1:
        file_names = sys.stdin
    else:
        file_names = argv[1:]
        
    for file_name in file_names:        # LOVE that polymorphism!
        if re.search("^\s*#", file_name):
            print >>sys.stderr, "# skipping:", file_name
            continue
        while file_name[-1] in "\r\n":
            file_name = file_name[:-1]
        ret.append(generate_commands(file_name))
    return ret
    
def print_commands(argv):
    print "#!/bin/sh"
    print "set -x"
    print
    commands = generate_all_commands(argv)
    #print "commands:", commands
    for demerge, emerge in commands:
        print demerge
        print emerge
    
def main(argv):
    import getopt
    options, args = getopt.getopt(sys.argv[1:], 'd:')

    for o, v in options:
        #print 'o>%s<, v>%s<' % (o, v)
        if o == '-d':
            debug = debug + 1
            continue
    print_commands(argv)
    
        
    # read lines of the form:
    # /var/db/pkg/sys-kernel/config-kernel-0.3.3/CONTENTS
    #     extract the package name
    #     remove the package (emerge -C)
    #     install the package (emerge)
    
if __name__ == "__main__":
    main(sys.argv)
