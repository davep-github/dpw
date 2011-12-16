#!/usr/bin/env python

import sys, socket, string

RC_NO_SUCH_HOST = 1
RC_NO_SUCH_ITEM = 2
RC_OK = 99

num_failures = 0

verbose = 0

#
# access the database
#
import dbt
db=dbt
db.prep()
import host_info
host_db = host_info.DB

#print host_db

if len(sys.argv) > 1:
    info_item = sys.argv[1]
else:
    # error, no args
    print >>sys.stderr, '%s: FATAL: No args passed' % sys.argv[0]
    help = """
host-info.py info_item [host [[domain]]

Return the requested INFO_ITEM from the designated HOST.  If host
is not specfied use the current host's name and domain.

E.g.:

$ host-info xterm_bg
blue
$ _
"""
    print >>sys.stderr, help
    sys.exit(1)

def lookup_item(info_item):

    if verbose:
        print 'try >%s< for >%s<' % (host, info_item)

    #
    # find the info for the host.
    # try given, then fqdn
    #
    rc = RC_OK
    try:
        info = host_db[host]
    except KeyError:
        try:
            fhost = host + '.' + domain
            if verbose:
                print 'try fqdn>%s< for >%s<' % (fhost, info_item)
            info = host_db[fhost]
        except KeyError:
            rc = RC_NO_SUCH_HOST

    #
    # found the db entry, now get the requested info
    if rc == RC_OK:
        # find the item
        try:
            x = info.get_item(info_item)
            print x
            raise 'SUCCESS'
        except AttributeError:
            pass

    #
    # any successful lookup throws an exception, so only
    # failures make it here.
    #
    global num_failures
    num_failures += 1
    print '-'

#
# parse args
#
host = None
domain = None
passed_domain = None
import getopt

# print >>sys.stderr, 'argv:', sys.argv
options, args = getopt.getopt(sys.argv[1:], 'h:d:v')
for (o, v) in options:
    if o == '-d':
        domain = v
    if o == '-h':
        host = v
    if o == '-v':
        verbose = 1

full_host = socket.getfqdn()
if not full_host:
    print >>sys.stderr, 'socket.getfqdn() failed.'
    sys.exit(22)

if not host or not domain:
    try:
        i = string.index(full_host, '.')
        thost = full_host[0:i]
        tdomain = full_host[i+1:]
    except ValueError:
        thost = full_host
        tdomain = None
    if not host:
        host = thost
    if not domain:
        domain = tdomain

    if verbose:
        print >>sys.stderr, 'host>%s<' % host
        print >>sys.stderr, 'domain>%s<' % domain
    
for item in args:
    try:
        lookup_item(item)
    except 'SUCCESS':
        pass
    
sys.exit(num_failures)
