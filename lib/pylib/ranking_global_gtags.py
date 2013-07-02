#!/usr/bin/env python

import sys, os, re, subprocess
import find_up
opath = os.path

## Make this environment specific
## In order of rank.
## Something like this.
#ranking_strings = os.environ.get("GLOBAL_TAGS_RANKING_STRINGS")
# split on ' ' or : or... quoting will be hard.

Top_ranking_regexp_strings = [
    "hw/ap_tlit1/drv/drvapi/runtest_surface",
    "hw/ap_tlit1/drv/drvapi/",
    "hw/ap_tlit1/drv/multiengine/",
    "hw/ap_tlit1/drv/chiplib/chiplib2/",
    "hw/ap_tlit1/drv/",
    "hw/tools/mods/trace_3d/plugin/",
    ]

Top_ranking_regexps = [ re.compile(regexp)
                        for regexp in Top_ranking_regexp_strings ]

## Genericize. elisp-devel has a good model based on xcscope's db scheme.

##finish class Data_file_return_t(object):
##finish     def __init__(self, file, rest_of_list):
##finish         self.d_file = file
##finish         self.d_rest_of_list = rest_of_list

##finish class Data_file_descriptor(object):
##finish     def __init__(self, dir, app_args):
##finish         self.d_dir = dir
##finish         self.d_app_args = app_args

##finish class Data_file_path_element(object):
##finish     def __init__(self, cwd_match_regexp, data_files):
##finish         self.d_cwd_match_regexp = cwd_match_regexp
##finish         self.d_data_files = data_files

##finish class Data_file_path_descriptor(object):
##finish     def __init__(self, data_file_name, path_elements):
##finish         self.d_data_file_name = data_file_name
##finish         self.d_path_elements = path_elements

Bottom_ranking_regexps = []
def rank_lines(lines):
    tops = []
    bottoms = []
    resid = []
    ## Find the rankest items.
    for regexp in Top_ranking_regexps:
        resid = []
        for line in lines:
            if regexp.search(line):
                tops.append(line)
            else:
                resid.append(line)
        if not resid:
            return tops + bottoms
        lines = resid
    # XXX @todo hanle bottom rankers here.
    return tops + resid + bottoms

def get_lines(fobj):
    lines = []
    for line in fobj:
        line = line[:-1]
        lines.append(line)
    return lines
    
def run_global(argv):
    #print >>sys.stderr, "run_global(argv: %s)" % (argv,)
    #print >>sys.stderr, "run_global(), cwd: %s" % (opath.realpath(opath.curdir,))
    glob = subprocess.Popen(["global"] + argv[1:], stdout=subprocess.PIPE)
    return get_lines(glob.stdout)

def run_globals_path(argv, path):
    """For each dir in path, cd there and try global there. Stop after first
    success."""
    start_dir = opath.realpath(opath.curdir)
    for p in path:
        p = opath.dirname(p)
        #print >>sys.stderr, "p>%s<" % (p,)
        os.chdir(p)
        x = run_global(argv)
        if x:
            x = [ opath.realpath(p) for p in x ]
        os.chdir(start_dir)
        if x:
            return x

def run_globals(argv, path=None, all_p=True):
    if path == None:
        path = find_up.find_up("GTAGS", all_p=all_p)
    return run_globals_path(argv, path)

def top_level_links_only(arg, dirname, fnames):
    print >>sys.stderr, "arg:", arg, "dirname:", dirname, "fnames:", fnames
    for fname in fnames:
        full_name = opath.join(dirname, fname)
        if opath.islink(full_name):
            arg.append(full_name)
    del fnames[:]
    
def main(argv):
    import getopt
    filter_p = os.environ.get("BEA_FILTER")
    # we need to pass everything to global, verbatim.
    #opt_string = "f"
    #opts, args = getopt.getopt(argv[1:], opt_string)
    #for o, v in opts:
    #    if o == '-f':
    #        filter_p = True
    #        continue

    # @todo XXX Very hard coded. Fix this.
    path = find_up.find_up("GTAGS", all_p=True)
    path.extend(Out_of_tree_dbs)

    if filter_p:
        lines = get_lines(sys.stdin)
    else:
        #lines = run_globals_path(argv, path)
        lines = run_globals(argv, path)
    if lines:
        lines = rank_lines(lines)
        for line in lines:
            print line

if __name__ == "__main__":
    main(sys.argv)
