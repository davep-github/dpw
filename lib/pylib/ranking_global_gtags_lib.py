#!/usr/bin/env python

import sys, os, re, subprocess
import find_up, dp_io, dp_sequences
opath = os.path

GLOBAL_PROGRAM_NAME = "global"
try:
    if log_file is not None:
        pass
except NameError:
    try:
        if LOG_FILE_NAME is None:
            log_file = dp_io.Null_dev_t()
        else:
            log_file = open(LOG_FILE_NAME, "a")
    except NameError:
        LOG_FILE_NAME = None
        log_file = dp_io.Null_dev_t()

Rgg_log_file_name = (os.environ.get("rgg_log_file_name", None)
                     or
                     os.environ.get("rgglfn"))
#Rgg_log_file_name = 'rgg.log'

def setup_logging(log_file_name=None):
    #rgg.log_file = sys.stderr
    #rgg_log_file_name = "bubba"
    #rgg_log_file_name = None
    global Rgg_log_file_name
    global log_file

    #print >>sys.stderr, "Rgg_log_file_name>%s<" % (Rgg_log_file_name,)
    if type(log_file) != "dp_io.Null_dev_t":
        if log_file_name:
            Rgg_log_file_name = log_file_name
        if Rgg_log_file_name:
            print >>sys.stderr, "Rgg_log_file_name>%s<" % (Rgg_log_file_name,)
            if Rgg_log_file_name == '--err':
                log_file = sys.stderr
            elif Rgg_log_file_name == '--out':
                log_file = sys.stdout
            else:
                Rgg_log_file_name = os.path.join(os.environ["HOME"], "var/log",
                                                 Rgg_log_file_name)
                log_file = open(Rgg_log_file_name, 'a')
        if not log_file:
            log_file = dp_io.Null_dev_t()
    #print >>sys.stderr, "log_file>%s<" % (log_file,)
    return log_file

## Make this environment specific
## In order of rank.
## Something like this.
#ranking_strings = os.environ.get("GLOBAL_TAGS_RANKING_STRINGS")
# split on ' ' or : or... quoting will be hard.

# The model [ at this time: 2013-07-12T10:11:37 ] is that this is used as a
# lib and is imported. The importer sets/overrides the appropriate variables
# to fit the specific application of this functionality.
Top_ranking_regexps = []
Filter_out_regexps = []

def add_top_ranking_regexp_strings(regexps):
    Top_ranking_regexps.extend([ re.compile(regexp) for regexp in regexps ])

def add_filter_out_regexp_strings(regexps):
    Filter_out_regexps.extend([ re.compile(regexp) for regexp in regexps ])

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

def rgg_parse_args(argv):
    argv = dp_io.parse_args()
    pass # for now

def uniqify_matches(lines):
    # Our use of global causes it to return multiple matches on the same
    # file:line.  However, for some reason, the lines have different amounts
    # of white space, even though they match the same line in the same file.
    # Let's uniqify the list.  First try is to just compress white space and
    # uniqify.  If this doesn't work (i.e if the white space is significant)
    # then we'll uniqify based on the compressed lines and return the
    # original lines.
    # Squished lines seem to work.
    new_lines = []
    for line in lines:
        line = " ".join(line.split())
        new_lines.append(line)
    lines = dp_sequences.uniqify_list_ordered(new_lines)
    return lines

Bottom_ranking_regexps = []
def rank_lines(lines):
    tops = []
    bottoms = []
    resid = []

    #log_file.write("rank_lines, lines>{}<\n".format(lines))
    log_file.write("rank_lines, lines>{}<\n".format("\n".join(lines)))
    log_file.write("Filter_out_regexps>{}<\n".format(Filter_out_regexps))
    log_file.write("Top_ranking_regexps>{}<\n".format(Top_ranking_regexps))
    if Filter_out_regexps:
        filtered_lines = []
        for line in lines:
            for regexp in Filter_out_regexps:
                if regexp.search(line):
                    line = None
                    break
            if line is not None:
                filtered_lines.append(line)
        lines = filtered_lines

    ## Find the rankest items.
    if not Top_ranking_regexps:
        # If there are no toppesting regexps, then these lines are at least
        # resid.
        resid.extend(lines)
    else:
        for regexp in Top_ranking_regexps:
            log_file.write("regexp>{}<\n".format(regexp.pattern))
            resid = []
            for line in lines:
                #log_file.write("line>{}<\n".format(line))
                if regexp.search(line):
                    log_file.write("line to tops>{}<\n".format(line))
                    tops.append(line)
                else:
                    log_file.write("line to resid>{}<\n".format(line))
                    resid.append(line)
            if not resid:
                return tops + bottoms
            lines = resid
    # XXX @todo handle bottom rankers here.
    all_lines = tops + resid + bottoms
    #log_file.write("all_lines>{}<\n".format(all_lines)

    return all_lines

Cxref_realpath_regexp = re.compile("(\S+)\s+(\d+)\s+(\S+)(.*)")
def get_lines(fobj, cxref_realpath_p=False, start_dir=opath.curdir):
    lines = []
    for line in fobj:
        line = line[:-1]
        if cxref_realpath_p:
            m = Cxref_realpath_regexp.search(line)
            if m:
                groups = m.groups()
                #print >>sys.stderr, "g[2]:", groups[2]
                #print >>sys.stderr, "start_dir:", start_dir
                p = opath.relpath(opath.realpath(groups[2]), start_dir)
                #print >>sys.stderr, "p:", p
                #line = (groups[0] + " " + groups[1] + " " + p)
                # Format copped from global source.
                # Needed to delete space before final %s because
                # Cxref_realpath_regexp grabs all spaces after path name.
                line = "%-16s %4s %-16s%s" % (groups[0], groups[1], p,
                                               groups[3])
                #print >>sys.stderr, "2, line:", line
        lines.append(line)
    #print >>sys.stderr, "lines:", lines
    return lines

def run_global(argv, start_dir=opath.curdir):
    #print >>sys.stderr, "run_global(argv: %s)" % (argv,)
    #print >>sys.stderr, "run_global(), cwd: %s" % (opath.realpath(opath.curdir,))
    if not opath.isfile("GTAGS"):
        return []
    log_file.write("run_global(): cwd: %s\n"
                       % (opath.realpath(opath.curdir,)))
    cxref_fmt = "-x" in argv
    log_file.write("run_global()cmdline>%s<\n" % ([GLOBAL_PROGRAM_NAME] + argv[1:]),)
    glob = subprocess.Popen([GLOBAL_PROGRAM_NAME] + argv[1:], stdout=subprocess.PIPE)
    lines = get_lines(glob.stdout, cxref_realpath_p=cxref_fmt,
                      start_dir=start_dir)
    return lines

def run_globals_over_path(argv, path, start_dir=opath.curdir,
                          all_matches_p=False,
                          first_db=0,
                          num_dbs=None):
    """For each dir in path, cd there and try global there. Stop after first
    success.
@todo XXX Keep going? """
    original_dir = opath.realpath(opath.curdir)
    if num_dbs is None:
        num_dbs = len(path)
    log_file.write("run_globals_over_path(): all_matches_p: {}\n".format(all_matches_p))
    log_file.write("run_globals_over_path(): first_db: {}\n".format(first_db))
    log_file.write("run_globals_over_path(): num_dbs: {}\n".format(num_dbs))
    log_file.write("run_globals_over_path(): BEFORE: path>{}<\n".format(path))
    path = path[first_db:num_dbs]
    log_file.write("run_globals_over_path(): AFTER: path>{}<\n".format(path))
    log_file.write("run_globals_over_path(): argv>{}<\n".format(argv))
    ret = []
    for p in path:
        p = opath.dirname(p)
        log_file.write("run_globals_over_path(): p>{}<\n".format(p))
        if opath.isdir(p):
            os.chdir(p)
            x = run_global(argv, start_dir=start_dir)
            #log_file.write("run_globals_over_path(): result[x]>{}<\n".format(x))
            log_file.write(
                "run_globals_over_path(): result[x]>{}<\n".format("\n".join(x)))
            os.chdir(original_dir)
            if x:
                ret.extend(x)
                if not all_matches_p:
                    break
    #log_file.write("run_globals_over_path(): ret>{}<\n".format(ret))
    log_file.write("run_globals_over_path(): ret>{}<\n".format("\n".join(ret)))
    return ret

def run_globals(argv, path=None, start_dir=opath.curdir,
                all_matches_p=False):
    if path == None:
        path = find_up.find_up("GTAGS", True)
    log_file.write("run_globals(): all_matches_p: {}\n".format(all_matches_p))
    if path != None:
        ret = run_globals_over_path(argv, path, start_dir=start_dir,
                                    all_matches_p=all_matches_p)
    else:
        ret = []
    #print "ret:", ret
    return ret

def top_level_links_only(arg, dirname, fnames):
    #print >>sys.stderr, "arg:", arg, "dirname:", dirname, "fnames:", fnames
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
        #lines = run_globals_over_path(argv, path)
        lines = run_globals(argv, path, start_dir=opath.curdir)
    if lines:
        lines = rank_lines(lines)
        for line in lines:
            print line

if __name__ == "__main__":
    main(sys.argv)
