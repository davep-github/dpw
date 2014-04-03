#!/usr/bin/env python

import sys, os, time, subprocess
import dp_sequences, dp_io, dp_utils

import ranking_global_gtags_lib
rgg = ranking_global_gtags_lib
#rgg.log_file = sys.stderr
rgg_log_file_name = os.environ.get("rgg_log_file_name", None)
if rgg_log_file_name:
    if rgg_log_file_name == '-':
        rgg.log_file = sys.stderr
    elif rgg_log_file_name == '--':
        rgg.log_file = sys.stdout
    else:
        rgg_log_file_name = os.path.join(os.environ["HOME"], "var/log",
                                         rgg_log_file_name)
        rgg.log_file = open(rgg_log_file_name, 'a')

rgg.log_file.write("==== {} ====\n".format(time.ctime()))

import find_up, p4_lib
opath = os.path

# Use [] so we fail messily if there is nothing defined.
DP_NV_DB_LOCSTR = os.environ["DP_NV_SRC_INDEX_DB_LOCS"]

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


Out_of_tree_dbs = ["/home/dpanariti/work/out-of-tree-dirs/GTAGS"]

Database_locations.extend(Out_of_tree_dbs)

Database_locations = [ loc for loc in Database_locations
                       if opath.exists(loc) ]

# Want to search upward from cwd for a db.
# Then want to search all other databases.

rgg.log_file.write("DP_NV_DB_LOCSTR>{}<\n".format(DP_NV_DB_LOCSTR))
rgg.log_file.write(
    "Database_locations>{}<\n".format(
        dp_sequences.list_to_indented_string(Database_locations)))

Top_ranking_regexp_strings = [
    # Old (yay) ME locations.
    "hw/ap_tlit1/drv/drvapi/include/runtest_surface",
    "hw/ap_tlit1/drv/drvapi/runtest_surface",
    "hw/ap_tlit1/drv/drvapi/",
    "hw/ap_tlit1/drv/multiengine/drvapi/cpu",
    "hw/ap_tlit1/drv/multiengine/",
    "hw/ap_tlit1/drv/chiplib/chiplib2/",
    "hw/ap_tlit1/drv/",
    "hw/tools/mods/trace_3d/plugin/",

    # NVLINK locations.
    "hw/nvgpu/fmod/nvlink_translator",
    "hw/nvgpu/fmod/xve_translator",
    ]

Filter_out_regexp_strings = [
    "cpu_surface_write_read",
    "cpu_mem_txn_swr",
    "/plex/"
    ]

rgg.add_top_ranking_regexp_strings(Top_ranking_regexp_strings)
rgg.add_filter_out_regexp_strings(Filter_out_regexp_strings)

def main(argv):
    filter_p = os.environ.get("BEA_FILTER")

    rgg_argv = os.environ.get("RGG_ARGV")
    if (rgg_argv):
        rgg.parse_args(rgg_argv)

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

    # Find this dir's parental db.
    path = find_up.find_up("GTAGS", all_p=True)
    rgg.log_file.write("path: %s\n" % \
                       dp_sequences.list_to_indented_string(path))
    # Add all other known db locations.
    # We should only add new elements.
    path.extend(Database_locations)
    dp_io.ctracef(1, "before uniq: path>{}<\n", "\n ".join(path))
    rgg.log_file.write("before uniq: path>{}<\n".format("\n ".join(path)))
    path = dp_sequences.uniquify_list(path)
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
        rgg.log_file.write("lines: %s\n" % \
                           dp_sequences.list_to_indented_string(lines))
        lines = rgg.rank_lines(lines)
        rgg.log_file.write("ranked lines: %s\n" % \
                           dp_sequences.list_to_indented_string(lines))
        for line in lines:
            print line
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
