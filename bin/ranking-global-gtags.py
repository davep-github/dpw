#!/usr/bin/env python

import sys, os, time, subprocess, re
import dp_sequences, dp_io, dp_utils

import ranking_global_gtags_lib
rgg = ranking_global_gtags_lib
#rgg.log_file = sys.stderr
rgg_log_file_name = os.environ.get("rgg_log_file_name", None)
if rgg_log_file_name:
    if rgg_log_file_name == '--err':
        rgg.log_file = sys.stderr
    elif rgg_log_file_name == '--out':
        rgg.log_file = sys.stdout
    else:
        rgg_log_file_name = os.path.join(os.environ["HOME"], "var/log",
                                         rgg_log_file_name)
        rgg.log_file = open(rgg_log_file_name, 'a')

rgg.log_file.write("==== {} ====\n".format(time.ctime()))

import find_up, p4_lib
opath = os.path

# Use [] so we fail messily if there is nothing defined.
DP_NV_DB_LOCSTR = os.environ.get("WORK_INDEX_DB_LOCS", "")

# Everything will search up to the sandbox root. There is one other known
# place and that is TOT
# Abbrev or //p4/loc name.
Database_p4_locations = DP_NV_DB_LOCSTR.split()
Database_locations = []
## Move this into ranking_global_gtags.py???

rgg_memo_file_name = "rgg_memo_file." + dp_utils.bq("dp4-get-root --basename")
rgg_memo_file = dp_utils.make_db_file_name(rgg_memo_file_name)
go_files, _ = dp_utils.process_gopath()
newest, _, _ = dp_utils.newest_file(go_files + [rgg_memo_file])

def create_db_locations(db_memo_file, dependencies, args):
    db_locations = []
    for dir in Database_p4_locations:
        rgg.log_file.write("Dir>{}<\n".format(dir))
        dir = p4_lib.p4_sb_location_to_absolute(dir)
        rgg.log_file.write("Dir>{}<\n".format(dir))
        if dir:
            dir = os.path.join(dir, "GTAGS")
            db_locations.append(dir)
    return db_locations

Database_locations = dp_utils.cheesy_memoized_file(
    rgg_memo_file,
    go_files,
    creator = create_db_locations,
    eval_p = True,
    write_new_p = True)


Out_of_tree_dbs = ["/home/davep/work/dpu/external/kernel/linux-3.10.0-229.1.2.el7/GTAGS",
                   "/home/davep/work/dpu/local/build/pcap-stuff/GTAGS"]

Database_locations.extend(Out_of_tree_dbs)

Database_locations = [ loc for loc in Database_locations
                       if opath.exists(loc) ]

# Want to search upward from cwd for a db.
# Then want to search all other databases.

rgg.log_file.write("DP_NV_DB_LOCSTR>{}<\n".format(DP_NV_DB_LOCSTR))
pretty_db_string = dp_sequences.list_to_indented_string(Database_locations)
rgg.log_file.write("Database_locations>{}<\n".format(pretty_db_string))

Top_ranking_regexp_strings = [
    ]

Filter_out_regexp_strings = [
    ]

rgg.add_top_ranking_regexp_strings(Top_ranking_regexp_strings)
rgg.add_filter_out_regexp_strings(Filter_out_regexp_strings)

def main(argv):
    filter_p = os.environ.get("BEA_FILTER")
    uniqify_p = True

    rgg_argv = os.environ.get("RGG_ARGV")
    if (rgg_argv):
        rgg.parse_args(rgg_argv)

    if argv[1] == '-d':
        for d in Database_locations:
            print "{}".format(opath.dirname(d))
        sys.exit(0)

    # we need to pass everything to global, verbatim. WHY?
    rgg.log_file.write("argv: %s\n" % \
                       dp_sequences.list_to_indented_string(argv))
    if argv[1] == '-pr':
        glob = subprocess.Popen(["global"] + argv[1:],
                                stdout=subprocess.PIPE)
        for line in glob.stdout:
            if line[-1] == '\n':
                line = line[:-1]
            if line:
                print line
        sys.exit(0)

    opt_cre = re.compile("--rgg-(.*)$")
    for arg in argv[1:]:
        opt = opt_cre.search(arg)
        if not opt:
            break
        opt = opt.group(1)
        if opt_name == "no-uniq":
            uniqify_p = False
            argv.delete(arg)
            continue

    #@todo XXX This should do this in every db searched.
#    if argv[1] in ('-u' '--update'):
#        sys.exit(subprocess.call(["global"] + argv[1:]))

    # Find this dir's parental db.
    path = find_up.find_up("GTAGS", all_p=True)
    rgg.log_file.write("path: %s\n" % \
                       dp_sequences.list_to_indented_string(path))
    # Add all other known db locations.
    # We should only add new elements.
    path.extend(Database_locations)
    dp_io.ctracef(1, "before uniq: path>{}<\n", "\n ".join(path))
    rgg.log_file.write("before uniq: path>{}<\n".format("\n ".join(path)))
    path = dp_sequences.uniqify_list(path)
    dp_io.ctracef(1, "after uniq: path>{}<\n", "\n ".join(path))
    rgg.log_file.write("after uniq: path>{}<\n".format("\n ".join(path)))

    rgg.log_file.write("extended path: %s\n" % \
                       dp_sequences.list_to_indented_string(path))

    rc = 0
    if filter_p:
        lines = get_lines(sys.stdin)
    else:
        #lines = run_globals_path(argv, path)
        lines = rgg.run_globals(argv, path,
                                start_dir=opath.realpath(opath.curdir))

    if lines:
        if uniqify_p:
            lines = rgg.uniqify_matches(lines)
            
        rgg.log_file.write("lines: %s\n" % \
                           dp_sequences.list_to_indented_string(lines))
        lines = rgg.rank_lines(lines)
        rgg.log_file.write("ranked lines: %s\n" % \
                           dp_sequences.list_to_indented_string(lines))
        rgg.log_file.write("output >>>>>>>>>>>>>>\n")
        for line in lines:
            print line
        rgg.log_file.write("<<<<<<<<<<<<<< output\n")
        rc = 0
    else:
        rgg.log_file.write("No matching lines.\n")
        #rc = 1
        ## emacs' gtags doesn't like non-0 return code.
        rc = 0
    rgg.log_file.write("=" * 17 + "\n")
    rgg.log_file.close()
    return rc

if __name__ == "__main__":
    sys.exit(main(sys.argv))
