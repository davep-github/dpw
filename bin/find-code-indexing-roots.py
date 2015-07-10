#!/usr/bin/env python

import os, sys, glob
import argparse
import dp_sequences

opath = os.path

########################################################################
## def find_roots(root, root_indicator_file, followlinks=False, max_depth=4):
##     ret = []
##     depth = 0
##     print >>sys.stderr, "root>{}<".format(root)
##     print >>sys.stderr, "root_indicator_file>{}<".format(root_indicator_file)
##     for dirpath, dirs, files in os.walk(root, followlinks=followlinks):
## ##         print >>sys.stderr, "dirpath>{}<, dirs>{}<, files>{}<".format(dirpath,
## ##                                                                       dirs,
## ##                                                                       files)
## ##         print >>sys.stderr, "dirpath>{}<, files>{}<".format(dirpath,
## ##                                                             files)
##         print >>sys.stderr, "dirpath>{}<".format(dirpath)
##         if root_indicator_file in files:
##             f = opath.join(dirpath, root_indicator_file)
##             print >>sys.stderr, "found one>{}<".format(f)
##             ret.append(f)
##         depth = dirpath[len(root) + len(opath.sep):].count(opath.sep)
##         if depth > max_depth:
##             dirs[:] = []
##     return ret

######################################################################
def find_roots(root, root_indicator_file, followlinks=False, max_depth=4):
    ret = []
    depths = {}
##     print >>sys.stderr, "root>{}<".format(root)
##     print >>sys.stderr, "root_indicator_file>{}<".format(root_indicator_file)
    for dirpath, dirs, files in os.walk(root, followlinks=followlinks):
        sub = dirpath[len(root) + len(opath.sep):]
##         print >>sys.stderr, "dirpath>{}<, sub>{}<, dirs>{}<, files>{}<".format(
##             dirpath, sub, dirs, files)

        comps = sub.split(opath.sep)
##         print >>sys.stderr, "comps>{}<".format(comps)
        if len(comps) < 2:
            continue
        r = comps[1]
        r = dirpath.split(opath.sep)[0]
##         print >>sys.stderr, "dirpath>{}<, files>{}<".format(dirpath,
##                                                             files)
        depth = depths.get(r, 0)
        depth = depth + 1
        if depth > max_depth:
            dirs[:] = []
        depths[r] = depth
##         print >>sys.stderr, "dirpath>{}<".format(dirpath)
        if root_indicator_file in files:
            f = opath.join(dirpath, root_indicator_file)
##             print >>sys.stderr, "found one>{}<".format(f)
            ret.append(f)
    return ret


## def find_roots(root, root_indicator_file, followlinks=False, max_depth=4):
##     import glob,os.path
##     glob_pat = ["."]
##     rf = [ root_indicator_file ]
##     files = {}
##     for i in range(max_depth):
##         pat = opath.join(*(glob_pat +  rf))
## ##         print "pat>{}<".format(pat)
##         glob_pat.append("*")
##         f = glob.glob(pat)
## ##         print "f>{}<".format(f)
##         for y in f:
##             x = opath.realpath(y)
##             files[x] = y
## ##             print "files>{}<".format(files)
##     return files.keys()

## def find_roots(root, root_indicator_file, followlinks=False, max_depth=4):
##     import glob,os.path
##     glob_pat = ["."]
##     rf = [ root_indicator_file ]
##     files = {}
##     for i in range(max_depth):
##         pat = opath.join(*(glob_pat +  rf))
## ##         print "pat>{}<".format(pat)
##         glob_pat.append("*")
##         f = glob.glob(pat)
## ##         print "f>{}<".format(f)
##         for y in f:
##             x = opath.realpath(y)
##             files[x] = y
## ##             print "files>{}<".format(files)
##     return files.keys()

########################################################################
def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug",
                         dest="debug_level",
                         type=int,
                         default=0,
                         help="Set debug level")
    oparser.add_argument("--max-depth", "--maxdepth",
                         dest="max_depth",
                         type=int,
                         default=4,
                         help="Max depth to search.")
    oparser.add_argument("--quiet", "-q",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
    oparser.add_argument("--env-var", "--hregexp", "--hmatch",
                         dest="env_var", default="DP_NV_ME_LOCS",
                         help='Try this env var for extra roots.')
    oparser.add_argument("--root-indicator-file", "--root-indicator",
                         dest="root_indicator_file", default="DP_INDEX_ROOT",
                         help='Try this env var for extra roots.')
    oparser.add_argument("--root", "--start",
                         dest="start_dir", default=".",
                         help='Start descending here.')
    oparser.add_argument("--follow-links", "--followlinks",
                         dest="follow_links_p", default=False,
                         action="store_true",
                         help='Should we follow symlinks?')


    # ...

    app_args = oparser.parse_args()

    DP_NV_DB_LOCSTR = os.environ.get("DP_NV_SRC_INDEX_DB_LOCS", "")
    env_roots = []
    if DP_NV_DB_LOCSTR:
        env_roots = DP_NV_DB_LOCS.split()
    found_roots = find_roots(root=app_args.start_dir,
                             root_indicator_file=app_args.root_indicator_file,
                             followlinks=app_args.follow_links_p,
                             max_depth=app_args.max_depth)

    roots = env_roots + found_roots
    # Filter out non-existent dirs.
    roots = [ r for r in roots if opath.exists(r) ]
    # Ensure only one copy of each.
    roots = dp_sequences.uniqify_list(roots)

    for r in roots:
        print r

########################################################################
if __name__ == "__main__":
    main(sys.argv)

