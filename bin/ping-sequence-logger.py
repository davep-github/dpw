#!/usr/bin/env python

import os, sys, re

seq_num = 0
last_seq_start = 0
tick_width = 10

IN_SEQ = 'in-seq'
OUT_SEQ = 'out-seq'

rex = re.compile("seq=(\d+)")

class line_printer:
    def __init__(self, ofile=None, tick='@'):
        self.need_newline = 0
        if ofile == None:
            self.ofile = sys.stderr
        else:
            self.ofile = ofile
        self.tick_mark = tick

    def lprint(self, fmt, *pargs):
        if pargs:
            fmt = fmt % pargs
            
        if self.need_newline:
            self.ofile.write('\n')
            self.need_newline = 0
        self.ofile.write(fmt)
        self.ofile.flush()

    def tick(self):
        self.ofile.write(self.tick_mark) ###  + ('[%d]' % seq_num))
        self.ofile.flush()
        self.need_newline = 1

def scan(lprinter):
    global seq_num
    global last_seq_start

    state = IN_SEQ

    while 1:
        l = sys.stdin.readline()
        if not l:
            break

        m = rex.search(l)
        if not m:
            sys.stderr.write("Unrecognized line format>%s<\n" % l)
            continue

        n = eval(m.group(1))
        # print ' --> %d <--' % n

        if state == OUT_SEQ:
            seq_num = n
            last_seq_start = seq_num
            state = IN_SEQ
            # print '*** resuming, seq:', seq_num
        else:
            if n != seq_num:
                # handle sequence break
                # print '*** seq break, got:', n, 'want: ', seq_num
                lprinter.lprint('last seq %d .. %d\n',
                               last_seq_start,
                               seq_num)
                last_seq_start = seq_num
                state = OUT_SEQ

        seq_num = seq_num + 1
        if seq_num and (seq_num % tick_width) == 0:
            lprinter.tick()

lprinter = line_printer()

try:
    scan(lprinter)
except KeyboardInterrupt:
    lprinter.lprint('^C, aborting.\n')
except Exception, e:
    lprinter.lprint('\ngot an exception>%s<\n', e)
    
lprinter.lprint('final seq %d .. %d\n', last_seq_start, seq_num)

