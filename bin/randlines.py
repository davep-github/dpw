#!/usr/bin/env python
### Time-stamp: <17/06/19 11:40:35 dpanarit>
#############################################################################
## @package 
##
import sys, os, types
import random


class Printor(object):
    def __init__(self, printor, *args, **kw_args):
        self.printor = printor
        self.args = args
        self.kw_args = kw_args

    def __call__(self, *args, **kw_args):
        self.printor(*args, **kw_args)

class FPrintor(Printor):
    def __init__(self, filo=sys.stdout, **kw_args):
        super(FPrintor, self).__init__(filo=filo, **kw_args)

    def __call__(self, fmt, *args, **kw_args):
        filo = kw_args.get("filo", self.filo)
        return filo.write(fmt % args)


def fprintf(f, fmt, *args):
    f.write(fmt % args)

def printf(fmt, *args):
    if not args:
        args = []
        args.append(fmt)
        fmt = "%s"
    fprintf(sys.stdout, fmt, *args)

def deal_em(l, random_range_fun=None):
    ret = []
    if not random_range_fun:
        random_range_fun = random.Random().randrange
    random.shuffle(l)
    return l

def print_em(lines, printor=printf, *printor_args):
    for l in lines:
        #print >>sys.stderr, "[%s]" % (l[0:-1],)
        printor(l)

def main(argv):
    import getopt
    seed = None
    interleave_p = False
    ofile = sys.stdout
    all_lines = []
    limit = None

    opt_string = "s:il:"
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        if o == '-s':
            seed = eval(v)
            continue
        if o == '-i':                   # Interleaved.
            interleave_p = True
            continue
        if o == '-l':
            limit = eval(v)
            continue
        #print >>sys.stderr, "Unhandled option>%s<" % (o,)
        sys.exit(1)

    files_or_names = args
    #print >>sys.stderr, "seed:", seed, ", files_or_names:", files_or_names

    random.seed(seed)

    if len(files_or_names) == 0:
        files_or_names = [sys.stdin]

    for f in files_or_names:
        if (type(f) == types.StringType):
            fo = open(f)
            close_p = True
        else:
            fo = f
            close_p = False

        l = fo.readlines()
        if limit:
            l = l[0:limit]
        if close_p:
            fo.close()
        if interleave_p:
            all_lines.extend(l)
        else:
            for l0 in l:
                l0 = l0[0:-1]
                #print >>sys.stderr, ">%s<" % (l0,)
            print_em(deal_em(l))
    if interleave_p:
        print_em(deal_em(all_lines))

if __name__ == "__main__":
    main(sys.argv)
