#!/usr/bin/env python

import os, sys, getopt, string, re, dp_io, types

# @todo add -F xxx, something to run on each line

class State:
    def __init__(self, sep_str=' ', flush_nl='\n'):
        self.infiles = []
        self.eval_input = 1
        self.indicate_EOF = 0
        self.EOL_function = None
        self.EOL_expression = None
        self.field_nums = []
        self.sep_str = sep_str
        self.flush_nl = flush_nl
        self.reset()

    def reset(self):
        self.oline = ''
        self.sep = ''
        self.e = []

    def emit(self, fmt, *rest):
        if rest:
            fmt = fmt % rest
        self.oline = self.oline + self.sep + fmt
        self.sep = self.sep_str

    def flush(self, ofiles):
        dp_io.fprintf(ofiles, '%s%s', self.oline, self.flush_nl)
        self.reset()

    def add_e(self, e):
        self.e.append(eval(e))
        #print 'add_e, e>%s<' % self.e

state = State()

options, args = getopt.getopt(sys.argv[1:], 'f:i:eEF:D:x:s:')
for (o, v) in options:
    if (o == '-f') or (o == '-i'):
        f = open(v)
        if not f:
            dp_io.eprintf('Cannot open >%s<\n', v)
            sys.exit(1)
        state.infiles.append(f)
    if o == '-e':
        state.eval_input = 0

    if o == '-E':
        state.indicate_EOF = 1

    if o == '-F':
        state.EOL_function = v

    if o == '-D':
        if v[0] == '@':
            f = open(v[1:])
            func = f.read()
            f.close
        else:
            func = v
        eval(func)

    if o == '-x':
        if v[0] == '@':
            f = open(v[1:])
            exp = f.read()
            f.close
        else:
            exp = v
        state.EOL_expression = exp

    if o == '-s':
        state.sep_str = v

#print 'state.sep_str>%s<' % state.sep_str

for fld in args:
    if fld.isdigit():
        state.field_nums.append(eval(fld))
    else:
        state.field_nums.append(fld)

def proc_line(line):
    fields = string.split(line)
    f = fields                          # for use in user expressions
    e = []
    for fld in fields:
        if fld[0].isdigit() and state.eval_input:
            e.append(eval(fld))
        else:
            e.append(fld)
            
    for fld in state.field_nums:
        try:
            if type(fld) == types.IntType:
                v = fields[fld]
            else:
                #dp_io.printf('fld>%s< ', fld)
                v = eval(fld)
                
            state.emit('%s', v)
            state.add_e(v)

        except IndexError:
            state.emit('<<<no-fld[%s]>>>', fld)

ofiles = (sys.stdout,)
nfiles = len(state.infiles)
if nfiles == 0:
    dp_io.eprintf('No input files specified.  Use -f <file> or -i <file>...\n')
    sys.exit(1)
    
eofs = [0] * nfiles
while min(eofs) == 0:
    for i in range(nfiles):
        if eofs[i]:
            if state.indicate_EOF:
                state.emit("<eof>")
            continue
        
        infile = state.infiles[i]
        line = infile.readline()
        if not line:
            eofs[i] = 1
            if state.indicate_EOF:
                state.emit("<hit-eof>")
            continue

        # skip comments and empty lines
        if re.search('^\s*#', line):
            continue
        if re.match('^\s*$', line):
            continue

        proc_line(line)

    if state.EOL_function:
        state.EOL_function(f, e)

    if state.EOL_expression:
        # make evaluated arg list easily available to user expressions
        e = state.e
        #print 'e>%s<' % e
        if e:
            state.emit('%s', eval(state.EOL_expression))
        
    state.flush(ofiles)
    
