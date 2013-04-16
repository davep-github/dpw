#!/usr/bin/env python

import sys, os, re, subprocess

## Make this environment specific
## In order of rank.
Top_ranking_regexps = [
    re.compile("hw/ap_tlit1/drv/drvapi/runtest_surface"),
    re.compile("hw/ap_tlit1/drv/drvapi/"),
    re.compile("hw/ap_tlit1/drv/multiengine/"),
    re.compile("hw/ap_tlit1/drv/"),
    re.compile("hw/tools/mods/trace_3d/plugin/"),
    ]

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
    glob = subprocess.Popen(["global"] + argv[1:], stdout=subprocess.PIPE)
    return get_lines(glob.stdout)
    
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

    if filter_p:
        lines = get_lines(sys.stdin)
    else:
        lines = run_global(argv)
    lines = rank_lines(lines)
    for line in lines:
        print line

if __name__ == "__main__":
    main(sys.argv)

