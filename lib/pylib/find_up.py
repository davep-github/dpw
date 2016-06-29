#!/usr/bin/env python

import sys, os, re
opath = os.path


# canonicalize path to either be real or apparent
def abs_canonicalize_path(p):
    return opath.normpath(opath.abspath(p))

def real_canonicalize_path(p):
    return opath.normpath(opath.realpath(p))

def make_path_from_components(components):
    p = opath.sep.join(components)
    rex = "%s%s+(.*)" % (opath.sep, opath.sep)
    #print >>sys.stderr, "rex>%s<" % (rex,)
    m = re.search(rex, p)
    if m:
        p = opath.sep + m.groups()[0]
        #print >>sys.stderr, "p>%s<" % (p,)
    return canonicalize_path(p)

# I made the symlinks for a reason.
canonicalize_path = abs_canonicalize_path

All_p = False
Dirs_too_p = True

def find_up(file_name, stop_dir="/", start_dir=None, all_p=False):
    global All_p
    All_p = all_p
    # print >>sys.stderr, "start_dir>%s<" % (start_dir,)
    # print >>sys.stderr, "stop_dir>%s<" % (stop_dir,)
    # print >>sys.stderr, "all_p>%s<" % (all_p,)
    if not start_dir:
        start_dir = os.environ["PWD"]   # This preserves link names.
    start_dir = canonicalize_path(start_dir)
    stop_dir = canonicalize_path(stop_dir)
    #print >>sys.stderr, "start_dir>%s<" % (start_dir,)
    #print >>sys.stderr, "stop_dir>%s<" % (stop_dir,)
    # The start dir will only get shorter.
    if not all_p and (len(stop_dir) > len(start_dir)):
        return None
    if start_dir == opath.sep:
        components = [opath.sep]
    else:
        components = start_dir.split(opath.sep)
        if components[0] == '':
            components[0] = opath.sep

    ret = []
    while components:
        # print >>sys.stderr, "components>%s<" % (components,)
        pwd = make_path_from_components(components)
        # print >>sys.stderr, "pwd>%s<" % (pwd,)
        pn_comps = [pwd, file_name]
        path_name = make_path_from_components(pn_comps)
        #print >>sys.stderr, "path_name>%s<" % (path_name,)
        if (opath.isfile(path_name)
            or
            (Dirs_too_p and opath.isdir(path_name))):
            if not all_p:
                return [path_name]
            else:
                #print >>sys.stderr, "Adding path_name>%s<" % (path_name,)
                ret.append(path_name)
        # print >>sys.stderr, "pwd>%s<" % (pwd,)
        # print >>sys.stderr, "stop_dir>%s<" % (stop_dir,)
        if pwd == stop_dir:
            # print >>sys.stderr, "stopping loop"
            break
        components = components[:-1]
    # print >>sys.stderr, "exiting loop, ret>%s<" % (ret,)
    return ret

def main(args):
    import getopt
    highest_p = False
    stop_dir = "/"
    start_dir = None                    # Use pwd.
    # Print this when file is not found to provide positional info about failure.
    global canonicalize_path
    global All_p
    global Dirs_too_p
    print_results_p = True
    # colon separated (if > 1 and print_results_p) path of dirs in which
    # found file(s) exist(s).
    print_as_path_p = False
    opts, args = getopt.getopt(sys.argv[1:], 'hs:S:pP:arAqd')
    for o, v in opts:
        if o == '-q':
            # Just produce a return code.
            print_results_p = False
            continue
        if o == '-h':
            highest_p = not highest_p
            continue
        if o == '-S':
            stop_dir = v
            continue
        if o == '-s':
            start_dir = v
            continue
        if o == '-p':
            # No sense in printing as a path unless we are searching for all
            # instances.
            print_as_path_p = True
            All_p = True
            continue
        if o == '-P':
            placeholder = v
            continue
        if o == '-r':
            canonicalize_path = real_canonicalize_path
            continue
        if o == '-a':
            canonicalize_path = abs_canonicalize_path
            continue
        if o == '-A':
            All_p = True
            continue
        if o == '-d':
            Dirs_too_p = False
            continue

    num_not_found = 0
    matches = []
    for file_name in args:
        n = find_up(file_name, stop_dir=stop_dir, start_dir=start_dir,
                    all_p=All_p)
        if not n:
            num_not_found += 1
        if n:
            matches.extend(n)

    print >>sys.stderr, "print_as_path_p:", print_as_path_p
    if print_results_p and len(matches) > 0:
        if print_as_path_p:
            matches = [opath.dirname(m) for m in matches]
            sep = ":"
        else:
            sep = "\n"
        match_string = sep.join(matches)
        print match_string

    return num_not_found

if __name__ == "__main__":
    sys.exit(main(sys.argv))

