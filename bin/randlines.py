#!/usr/bin/env python
### Time-stamp: <08/06/29 13:48:57 davep>
#############################################################################
## @package 
##
import sys, os
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
    fprintf(sys.stdout, fmt, *args)
    
def deal_em(l, random_range_fun=None, handlor=None):
    ret = []
    if not random_range_fun:
        random_range_fun = random.Random().randrange
    llen = len(l)
    while llen:
        r = random_range_fun(0, llen-1)
        i = l[r]
        if handlor:
            handlor(i)
        ret.append(i)
        del l[r]
        llen -= 1
    return ret

def print_em(l, printor=printf):
    deal_em(handlor=printor)

def main(files_or_names):
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
        if close_p:
            fo.close()

        print_em(l)

if __name__ == "__main__":
    main(sys.argv[1:])
