#!/usr/bin/env python

import sys, os
import random

verbosity = 0
verbosity_stream = sys.stderr

def verbose(fmt, *args):
    if verbosity:
        verbosity_stream.write(fmt % args)

def gen_nums(ostream, num_files, unique_percent, num_unique_files=None,
             seed_base=0):
    if num_unique_files:
        num_uniq = num_unique_files
    else:
        num_uniq = int(num_files * unique_percent)
    if num_uniq == 0:
        num_uniq = 1
    num_dups = num_files - num_uniq
    verbose("num_uniq: %d, num_dups: %d\n", num_uniq, num_dups)
    nums = range(seed_base, num_uniq)
    for i in range(num_dups):
        nums.append(nums[i])
    return nums

def randomize_list(nums_in, seed):
    random.seed(seed)
    nums = nums_in[:]
    r_nums = []
    while nums:
        i = random.randint(0, len(nums)-1)
        r_nums.append(nums[i])
        nums.pop(i)
        #print "post-pop nums:", nums
    return r_nums

def print_nums(ostream, nums, annotate_p=False):
    if not annotate_p:
        for s in nums:
            print s
    else:
        seen = {}
        anno = ""
        for s in nums:
            if seen.get(s, None) == None:
                anno = "orig"
                seen[s] = 0
            else:
                anno = "dup-%010d" % seen[s]
                seen[s] += 1
            print s, anno
        
def main(argv):
    import getopt
    global verbosity
    ordered_p = False
    annotate_p = False
    opt_string = "p:n:b:s:r:voau:"
    unique_percent = 0.5
    num_files = None
    seed_base = 0
    rand_output_seed = 0
    num_unique_files = None
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-p':
            unique_percent = eval(v)
            continue
        if o == '-u':
            num_unique_files = eval(v)
            continue
        if o == '-n':
            num_files = eval(v)
            continue
        if o == '-r':
            rand_output_seed = eval(v)
            continue
        if o == '-v':
            verbosity = 1
            continue
        if o == '-o':
            ordered_p = True
            continue
        if o == '-a':
            annotate_p = True

    if not num_files:
        print >>sys.stderr, "I need a non-zero number of files, not>%s<" % \
              num_files
        sys.exit(1)
    unique_percent = float(unique_percent)
    if unique_percent > 1.0:
        unique_percent = unique_percent / 100
    nums = gen_nums(sys.stdout, num_files, unique_percent, num_unique_files,
                    seed_base)
    if ordered_p:
        r_nums = nums[:]
    else:
        r_nums = randomize_list(nums, rand_output_seed)
    sorted_nums = nums[:]
    sorted_nums.sort()
    sorted_r_nums = r_nums[:]
    sorted_r_nums.sort()

    verbose("nums: %s\n", nums)
    verbose("r_nums: %s\n", r_nums)
    verbose("sorted_nums: %s\n", sorted_nums)
    verbose("sorted_r_nums: %s\n", sorted_r_nums)

    # Sanity check.
    if sorted_nums != sorted_r_nums:
        print >>sys.stderr, "sorted random nums don't match"
        print >>sys.stderr, "sorted_nums:", sorted_nums
        print >>sys.stderr, "sorted_r_nums:", sorted_r_nums
        sys.exit(1)

    print_nums(sys.stdout, r_nums, annotate_p=annotate_p)
    
if __name__ == "__main__":
    main(sys.argv)


