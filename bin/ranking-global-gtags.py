#!/usr/bin/env python

import os, sys

import ranking_global_gtags_main
rgg = ranking_global_gtags_main

# Add regexps that allow multiple GNU global matches to be ranked in some
# useful manner.  For example, a subtree's definition of a function is
# probably more useful and should be placed higher in the list (although one
# should argue that using name spaces in C++ or some kind of prefix scheme in
# C would be the better method.).
# Redefinitions, unless for polymorphism tend to be troublesome.
Top_ranking_regexp_strings = [
    "gpu/drm/amd/amdkfd/",
    "gpu/drm/amd/amdgpu/",
    "gpu/drm/amd/",
    "gpu/drm/",
    "gpu/",
]

Filter_out_regexp_strings = [
    ]

def main(argv):
    rgg.rank_init(Top_ranking_regexp_strings,
                  Filter_out_regexp_strings)
    rgg.rank_main(argv)

if __name__ == "__main__":
    main(sys.argv)

