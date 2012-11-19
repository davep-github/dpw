#!/usr/bin/env python

import os, sys, re, string, time

# Mark:
# This program is called as a filter by getmail, an email retrieval tool
# built in Python.  In fact I would suggest looking into it as the
# fetch/front-end for your project.  It is a very reliable front end.  And it
# is extensible in Python to add new types of functionality.  It may fit in
# quite well.

# Keep a log file so we can debug if something goes wrong.
log_file = '/home/davep/log/auto-rotate-c10-50K/' + \
           os.path.basename(sys.argv[0]) + '.log'

def check_for_ping(istr, ostr, log):
    # Make sure there's an @ in the return addr part.  Search for a
    # Subject-like line with the key string 'ping-back:' And make sure that
    # something remotely email address like follows.  Since this kind of
    # email is only sent by me for me, there is no other error checking
    # besides ensuring an `@' sign.  For more safety, Python's rfc822 parsing
    # routines should be used.  re.compile compiles the regular expression so
    # that it executes faster.  While not needed in this case, it can make a
    # huge difference when the regexp is compiled outside of a large loop.  I
    # compile as a matter of course.
    rex = re.compile('^\s*Sub.*:.*ping-back:\s*(\S+@\S+)')

    # We are processing this email on the fly.  So we scan for the Subject
    # line as we copy lines to the output stream.  Once we find the subject
    # line of interest, we set a flag and then we become essentially a cat
    # command.
    mailed = False
    while True:
        # Read lines from our input stream.
        l = istr.readline()
        if not l:                       # EOF?
            break
        m = rex.search(l)
        if not mailed and m:
            log.write("==== " + time.ctime() + " ===\n")
            # Create mail back command based on regexp search results.
            # Backslashing to continue lines SUCKS!
            cmd = "mail -s ping-back %s < /dev/null >/dev/null 2>&1" % \
                  m.group(1)
            log.write("line>%s<\n" % l[:-1])
            log.write("cmd: %s\n" % cmd)
            # Run the command we built.
            os.system(cmd)
            mailed = True
        ostr.write(l)

# __name__ == __main__ when this file is executed directly.  This file can
# also be `import'ed into another file.  That file will then have access to
# the function check_for_ping(), but check_for_ping() won't be called until
# the importing file decides to.  This allows Python programs to be
# stand-alone utilities and to be imported and used as libraries to add
# functionality in other places.
if __name__ == "__main__":
    log = open(log_file, "a")
    check_for_ping(sys.stdin, sys.stdout, log)
    log.close()
    sys.exit(0)
        
