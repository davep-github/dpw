#!/usr/bin/env python

import sys, os, time
import ranking_global_gtags_lib, dp_sequences
rgg = ranking_global_gtags_lib

import find_up, p4_lib
opath = os.path

# Everything will search up to the sandbox root. There is one other known
# place and that is TOT
Database_p4_locations = [ "ap" ]        # Abbrev name.
Database_locations = []
## Move this into ranking_global_gtags.py
for dir in Database_p4_locations:
    dir = p4_lib.p4_sb_location_to_absolute(dir)
    if dir:
        dir = os.path.join(dir, "GTAGS")
        Database_locations.append(dir)

Out_of_tree_dbs = ["/home/dpanariti/work/out-of-tree-dirs/GTAGS"]

Database_locations.extend(Out_of_tree_dbs)

# Want to search upward from cwd for a db.
# Then want to search all other databases.

rgg.log_file.write("\n=========\n" + time.ctime() + "\n")

Top_ranking_regexp_strings = [
    "hw/ap_tlit1/drv/drvapi/include/runtest_surface",
    "hw/ap_tlit1/drv/drvapi/runtest_surface",
    "hw/ap_tlit1/drv/drvapi/",
    "hw/ap_tlit1/drv/multiengine/drvapi/cpu",
    "hw/ap_tlit1/drv/multiengine/",
    "hw/ap_tlit1/drv/chiplib/chiplib2/",
    "hw/ap_tlit1/drv/",
    "hw/tools/mods/trace_3d/plugin/",
    ]

rgg.add_top_ranking_regexp_strings(Top_ranking_regexp_strings)

def main(argv):
    filter_p = os.environ.get("BEA_FILTER")

    rgg_argv = os.environ.get("RGG_ARGV")
    if (rgg_argv):
        rgg.parse_args(rgg_argv)

    # we need to pass everything to global, verbatim. WHY?
    rgg.log_file.write("argv: %s\n" % \
                       dp_sequences.list_to_indented_string(argv))
    path = find_up.find_up("GTAGS", all_p=True)
    rgg.log_file.write("path: %s\n" % \
                       dp_sequences.list_to_indented_string(path))
    path.extend(Database_locations)
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
