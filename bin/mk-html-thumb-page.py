#!/usr/bin/env python
# $Id: mk-html-thumb-page.py,v 1.1 2001/03/03 04:05:38 davep Exp $
#
# Create a directory in html.  Make a link for each item in the
# specified directory
#
# prog [-f re] dir...

import os, sys, string, getopt, re, fnmatch

filter = '*'

options, args = getopt.getopt(sys.argv[1:], 'f:')
for (o, v) in options:
    if o == '-f':
        filter = v

if len(args) == 0:
    args = ('.')
    
# /usr/local/etc/apache/httpd.conf:DocumentRoot /usr/local/www/data
www_root = os.popen('grep \'^DocumentRoot\' /usr/local/etc/apache/httpd.conf').read()
# print 'www_root:', www_root
www_root = string.strip(www_root)
m = re.search('^DocumentRoot\s+"?(\S+?)"?$', www_root)
if not m:
    raise "Cannot find doc root"
www_root = m.group(1)

back = os.getcwd()
os.chdir(www_root)
www_root = os.getcwd()

for dir in args:
    os.chdir(back)
    os.chdir(dir)
    files = os.popen('ls -1').readlines()
    dir_str = os.getcwd()
    # print "dir_str>%s<, www_root>%s<" % (dir_str, www_root)
    prefix = os.path.commonprefix((dir_str, www_root))
    if prefix:
        dir_str = dir_str[len(prefix)+1:]
    else:
        dir_str = ''
        
    dir_str = '$WWW_ROOT/%s' % dir_str
    dir_str = "Directory listing of " + dir_str

    print "<HTML>"
    print "<BODY>"
    print "<TITLE>\n%s\n</TITLE>" % dir_str
    print "<H2>\n%s\n</H2>" % dir_str

    print "<P>\n<P>\n"

    # examples of anchors
    #<a href="pics/rwrap.jpg">what we got</a>
    #<A HREF="16weeks.jpg"><IMG SRC="16weeks_thumb.jpg" HEIGHT=76 WIDTH=80 ALIGN=ABSCENTER></A>
    for file in files:
        file = string.strip(file)
	thumb = "thumbs/%s" % file
        if not os.path.isfile(thumb):
            continue
        if not fnmatch.fnmatch(file, filter):
            continue
	print '<A HREF="%s"><IMG SRC="%s" ALIGN=ABSCENTER></A>' % (file, thumb)

    print
    print "</BODY>"
    print "</HTML>"
