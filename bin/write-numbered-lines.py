#!/usr/bin/env python

import os, sys, string
import dp_io

if len(sys.argv) < 2:
    dp_io.eprintf("I need a <len-in-bytes> arg\n");
    sys.exit(1)


desired_size = int(sys.argv[1])

num = 0;
file_size = 0

while 1:
    if (file_size >= desired_size):
        break

    print num
    file_size = file_size + len('%s\n' % num)
    num = num + 1
    

    
