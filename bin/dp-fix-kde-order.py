#!/usr/bin/env python

import sys, os, string, re

def fix_kde_order(num_to_retain):
    path0 = string.split(os.environ["PATH"], ":")
    #print "path:", path
    # Separate the components of the current PATH:
    kde_path = []
    path = []
    for p in path0:
	if re.search("kde", p):
	    kde_path.append(p)
	else:
	    path.append(p)
    kde_path.sort(reverse=True)
    #print "path0:", path0
    #print "kde_path:", kde_path
    #print "path:", path
    return string.join(path + kde_path[0:num_to_retain], ":")

def main(args):
    if len(args) > 1:
	n = eval(args[1])
    else:
	n = 1
    print fix_kde_order(n)

if __name__ == "__main__":
    main(sys.argv)
