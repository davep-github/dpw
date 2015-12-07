#!/usr/bin/env python

#
# davep's standard new Python file template.
#

import os, sys
import argparse
import dp_io

import ranking_global_gtags_main
rgg = ranking_global_gtags_main

# /proj/ras_arch/users/dpanarit/work/ras/edc/linux/drivers/...
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

