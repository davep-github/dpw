#!/usr/bin/env python

import sys, os, argparse
import dp_io, find_up
opath = os.path

# Create a config system.
# try ./some_config.py
# then pylib/some_config.py

Configuration = {
    "ROOT_INDICATOR_FILE": "DP_SB_ROOT"
    }

def main(argv):
    oparser = argparse.ArgumentParser()
    oparser.add_argument("--find-root", "--sb-root",
                         dest="find_root_p",
                         action="store_true",
                         help="Find the sandbox root.")
    oparser.add_argument("--relativize",
                         dest="name_to_relativize", default="",
                         type=str,
                         help="Print name relative to sb_root")

    app_args = oparser.parse_args()

    rif = Configuration["ROOT_INDICATOR_FILE"]
    sandbox_path = find_up.find_up(rif)
    if sandbox_path:
        sandbox_path = opath.dirname(sandbox_path[0])
        sandbox_path = opath.normpath(opath.realpath(sandbox_path))
    else:
        eprintf("cannot find root_indicator_file[%s]\n", rif)

    if app_args.find_root_p:
        if sandbox_path:
            print sandbox_path

    if app_args.name_to_relativize:
        name = opath.normpath(opath.realpath(app_args.name_to_relativize))
        p = name.find(sandbox_path)
        if p == 0:
            name = name[len(sandbox_path) + 1:]
            print name
            

    for arg in argv:
        # Handle arg
        pass

if __name__ == "__main__":
    main(sys.argv)

