#!/usr/bin/env python

import sys, os
from ranking_global_gtags import *
import find_up
opath = os.path

Out_of_tree_dbs = ["/home/dpanariti/work/out-of-tree-dirs/GTAGS"]

Top_ranking_regexp_strings = [
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
