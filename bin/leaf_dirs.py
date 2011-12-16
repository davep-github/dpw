#!/usr/bin/env python

import os, sys, string

def find_leaf_dirs_func(data, dirname, fnames):
    cwd, leaf_dirs = data
    
    ##print 'dirname>%s<' % dirname
    dirname = os.path.join(cwd, dirname)
    dirname = string.replace(dirname, '/./', '/')
    ##print 'dirname>%s<' % dirname

    ###print "  ", string.join(fnames, "\n  ")
    for f in fnames:
        f = os.path.join(dirname, f)
        ##print "checking>%s<, dirness>%s<" % (f, os.path.isdir(f))
        if os.path.isdir(f):
            return                      # not a leaf, it contains a dir
    leaf_dirs.append(dirname)

def find_leaf_dirs(dir):
    if dir[0] != '/':
        cwd0 = os.path.realpath('.')
    else:
        cwd0 = ''

    leaves = []
    os.path.walk(dir, find_leaf_dirs_func, (cwd0, leaves))
    return leaves

if __name__ == "__main__":
    argc = len(sys.argv)
    if argc > 1:
        dir = sys.argv[1]
    else:
        dir = "/media/audio/music/mp3"

    leaves = find_leaf_dirs(dir)

    print "leaves:"
    print string.join(leaves, '\n')
    
#     mp3dir = '/media/audio/music/mp3'
#     import ppn
#     ppn.purify_path_list(leaves, dir)

