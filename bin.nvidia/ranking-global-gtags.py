#!/usr/bin/env python

import sys, os, time
from ranking_global_gtags import *
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

rgg_log_file.write("\n=========\n" + time.ctime() + "\n")

def list_to_indented_string(l):
    return "\n  ".join(l)
    

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

add_top_ranking_regexp_strings(Top_ranking_regexp_strings)

def main(argv):
    import getopt
    filter_p = os.environ.get("BEA_FILTER")
    # we need to pass everything to global, verbatim.
    rgg_log_file.write("argv: %s\n" % list_to_indented_string(argv))
    path = find_up.find_up("GTAGS", all_p=True)
    rgg_log_file.write("path: %s\n" % list_to_indented_string(path))
    path.extend(Database_locations)
    rgg_log_file.write("extended path: %s\n" % list_to_indented_string(path))

    rc = 0
    if filter_p:
        lines = get_lines(sys.stdin)
    else:
        #lines = run_globals_path(argv, path)
        lines = run_globals(argv, path, start_dir=opath.realpath(opath.curdir))
    if lines:
        rgg_log_file.write("lines: %s\n" % list_to_indented_string(lines))
        lines = rank_lines(lines)
        rgg_log_file.write("ranked lines: %s\n" % list_to_indented_string(lines))
        for line in lines:
            print line
        rc = 0
    else:
        rgg_log_file.write("No matching lines.\n")
        #rc = 1
        ## emacs' gtags doesn't like non-0 return code.
        rc = 0
    rgg_log_file.write("=" * 17 + "\n")
    rgg_log_file.close()
    return rc

if __name__ == "__main__":
    sys.exit(main(sys.argv))
