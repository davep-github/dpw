#!/usr/bin/env python

link_re = '(\S+)\s+->\s+(\S+)$'
doc = """usage: restore-symlinks.py [-i <pat>] [-e|-x <pat>] [-Xwqav]

Take the output of a ``find -type l -ls'' or ``ls -l'' and
generate a script to resore the links listed.
It will actually work with any file that contains links expressed
as: link -> real-file, i.e. matching ``%s''.
This is mainly intended to restore symlinks after a module is
checked out of cvs.  It may be easiest to redirect the output to a
file, edit the file and then execute the file.

Options:
  -i <pat>\tInclude lines matching the re <pat>.  Once a -i is seen,
\t\ta line will be rejected if no -i <pat> specified matches.
  -x <pat>\tExclude lines matching the re <pat>.  Immediately a
\t\t-x <pat> matches, the line is excluded, even if a subsequent
\t\t-i <pat> would have matched.
  -e <pat>\tSame as -x <pat>
  -X\t\tExecute ln -s commands as well as printing them.
  -w\t\tDon't print warnings about absolute links.
  -q\t\tDon't print excluded lines as comments.
  -a\t\tDon't print absolute links.
  -v\t\tVerify that linked to file exists.""" % (link_re)

import sys, os, string, re, dp_io, getopt

filters = []
execute = 0
ABS_LINK_WARNING = '\t# *** ABSOLUTE LINK ****'
dont_print_excluded_lines = 0
dont_print_absolute_links = 0
verify_links = 0
verify_error = ""
ask = 0

try:
    options, args = getopt.getopt(sys.argv[1:], 'i:e:x:Xwq:avA')
    for (o, v) in options:
        if o == '-i':
            filters.append(('include', v))
        if o == '-e' or o == '-x':
            filters.append(('exclude', v))
        if o == '-X':
            execute = 1
        if o == '-w':
            ABS_LINK_WARNING = ''
        if o == '-q':
            dont_print_excluded_lines = 1
        if o == '-a':
            dont_print_absolute_links = 1
        if o == '-v':
            verify_links = 1
        if o == '-A':
            ask = 1
            
except getopt.GetoptError, e:
    dp_io.eprintf("%s\n", e)
    dp_io.eprintf("%s\n", doc)
    sys.exit(1)

#print filters
line = sys.stdin.readline()
if line:
    rex = re.compile(link_re)
    while 1:
        line = sys.stdin.readline()
        if not line:
            break
        
        m = rex.search(line)
        if not m:
            dp_io.eprintf('cannot find files in line>%s<\n', line)
            continue
        
        src = m.group(2)
        dst = m.group(1)
        dst = os.path.normpath(dst)
        if src[0] != '/':
            # relative link, fix up the dst
            dir = os.path.dirname(dst)
            src = os.path.join(dir, src)
            src = os.path.normpath(src)
            warning = ''
        else:
            if dont_print_absolute_links:
                continue
            warning = ABS_LINK_WARNING

        match_str = src + ' ' + dst

        cont = None
        for op, pat in filters:
            m = re.search(pat, match_str)
            if op == 'include':
                if m:
                    cont = 1
                    break
                else:
                    cont = 0
                    
            if op == 'exclude' and m:
                cont = 0
                break

        oline = 'ln -s %s %s' % (src, dst)
        oline2 = '%s%s' % (oline, warning)
        if cont == 0:
            if not dont_print_rejected_lines:
                print '# (rejecting)', oline2
            continue

        verify_error = ''
        if verify_links and not os.access(src, os.F_OK):
            verify_error = '# '

        print '%s%s' % (verify_error, oline2)

        if verify_error:
            leader = '^' * len(src)
            print '#       %s does not exist' % (leader,)
            continue
        
        if execute:
            if ask:
                print 'Link it ?',
                ans = sys.stdin.readline()
                doit = ans in 'yY1tT'
            else:
                doit = 1
            if doit:
                rc = os.system(oline)
                if rc != 0:
                    dp_io.eprintf("oline>%s< failed, rc: %d", oline, rc)
                    sys.exit(1)
