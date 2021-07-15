#!/usr/bin/env python

import sys, socket, string, os, re
import dp_io

RC_NO_SUCH_HOST = 1
RC_NO_SUCH_ITEM = 2
RC_OK = 99

class Success_t(Exception):
    def __init__(self, *args, **kargs):
        # super not in 2.4#super(Success_t, self).__init__(*args, **kargs)
        Exception.__init__(self, *args, **kargs)

    def __str__(self):
        return "Success_t"

SUCCESS = Success_t()

num_failures = 0

## @todo XXX Fix all uses to use dp_io.*verbose* type stuff.
verbose = 0
not_found_strings = []
default_search = True
items = []

#
# access the database
#
import dppydb
#db=dbt

#print host_db

if len(sys.argv) > 1:
    info_item = sys.argv[1]
else:
    # error, no args
    dp_io.eprintf('%s: FATAL: No args passed\n', sys.argv[0])
    help = """
host-info.py [-h host] [-d domain] [-v] [-n not-found-string] info_item...

Return the requested INFO_ITEM from the designated HOST.
If host/domain are not specfied use the current host's name/domain.
If the info item is not found, return '-' or not-found-string.

E.g.:

$ host-info.py xterm_bg non_existent_item
blue
-
$ _
"""
    dp_io.eprintf(help)
    sys.exit(1)

class Dumper_t(object):
    def __init__(self, ostream=sys.stdout):
        self.ostream = ostream

    def switch_streams(self, ostream, close_p=False):
        if close_p and self.ostream:
            self.ostream.close()
            self.ostream = None
        self.ostream = ostream

    def simple_emit(self, str, new_line=True):
        self.ostream.write(str)
        if new_line:
            self.ostream.write('\n')

    def not_found(self, info_item, not_found_string='-', new_line=True):
        self.simple_emit(not_found_string, new_line=new_line)

    def found(self, info_item, data, new_line=True):
        dp_io.ctracef(3, 'Dumper_t.found(): >{}< for >{}<\n', info_item, data)
        self.simple_emit(data, new_line=new_line)

Def_dumper = Dumper_t()

############################################################################
def dump_all(info_list):
    for info in info_list:
        info.print_fields(sortem=1)

    raise SUCCESS

############################################################################
def match_family_by_host(host):
    # XXX @todo Will need to preserve order somehow.
    dp_io.ctracef(2, "match_family_by_host({})", host)

    def strcmp(s1, s2):
        return s1 == s2

    node_name = host_db.get(dppydb.famDB_to_node_name(), None)
    dp_io.ctracef(2, "node_name>{}<", node_name)

    if node_name:
        famDB = node_name.get_item('db')

        # check for exact matches first.
        dp_io.ctracef(2, "match_family_by_host({})", host)
        for (field_name, cmp_fun) in (("host", strcmp),
                                      ("host-pattern", re.search),
                                      ("host-default-pattern", re.search)):
            dp_io.ctracef(2, "match_family_by_host({})", host)
            families = famDB.grep_fields(field_name)
            for fam in families:
                field_value = fam.get_item(field_name)
                if cmp_fun(field_value, host):
                    return (RC_OK, (fam,))

    return RC_NO_SUCH_HOST, RC_NO_SUCH_HOST  # Need to return a tuple
    
############################################################################
def lookup_item(info_item, not_found_string='-', dumper=Def_dumper,
                locale_search=True, domain_search=True,
                default_search=True,
                wildcard_match=True,
                dump_all_fields=False):
    if verbose:
        print('try >%s< for >%s<' % (host, info_item))
        dp_io.ctracef(2, 'try >%s< for >%s<' % (host, info_item))

    #
    # find the info for the host.
    # try given, then fqdn
    #
    rc = RC_OK
    try:
        info = (host_db[host],)
    except KeyError:
        dp_io.ctracef(5, "D'OH!, no host>{}<\n".format(host))
        # there's no entry named host in the db.
        # try the fqdn if there is a domain available.
        try:
            dp_io.ctracef(2, "domain>{}<\n".format(domain))
            if not domain:
                raise KeyError
            fhost = host + '.' + domain
            if verbose:
                print('try fqdn>%s< for >%s<' % (fhost, info_item))
            info = (host_db[fhost],)
        except KeyError:
            # there is no entry for this host.
            # search for a default from one of
            # family or default
            # this is for the case of an unlisted host.
            # while the host may be unspecified, there may
            # be a record for the locale in which it resides.
            # NB: since we currently use host-info to determine
            # a host's family, etc., if a host is unlisted, then
            # we need to get that info elsewhere.
            rc = RC_NO_SUCH_HOST
            info = []
            if domain_search and domain:
                domain_host = dppydb.domain_to_node_name(domain)
                inf = host_db.get(domain_host, None)
                if verbose:
                    print('try domain>%s<, domain_host>%s<' % (domain,
                                                               domain_host))
                    print('info>%s<' % info)
                if inf:
                    rc = RC_OK
                    info.append(inf)
                    if verbose:
                        print('domain hit, info>%s<.' % info)
                        if verbose > 1:
                            print('%s' % inf.ret_fields())

            if rc == RC_NO_SUCH_HOST and wildcard_match:
                rc, info = match_family_by_host(host)
            if rc == RC_NO_SUCH_HOST and locale_search:
                locale_rcs = os.environ.get('locale_rcs', '')
                if verbose:
                    print('try locale_rcs {%s}' % locale_rcs)
                    # host_db.dump('a')
                    if verbose > 1:
                        print("items in host_db.keys")
                        for k, v in list(host_db.keys.items()):
                            print('k>%s<, v>%s<' % (k, v))

                info = []
                locs = str.split(locale_rcs)
                locs.reverse()          # order most specific first
                for fam in locs:
                    fam = fam[1:]       # strip . from element
                    if verbose:
                        print('fam>%s<' % fam)
                    if not fam:
                        continue
                    #
                    # convert the family name to a node name
                    # we use a node name since that is our
                    # index field.
                    # we use routines in dppydb to generate a node
                    # name that is illegal for a real internet
                    # node name, but is a legal python string.
                    fam_host = dppydb.family_to_node_name(fam)
                    inf = host_db.get(fam_host, None)
                    if verbose:
                        print('try fam>%s<, fam_host>%s<' % (fam, fam_host))
                        print('info>%s<' % info)
                    if inf:
                        rc = RC_OK
                        info.append(inf)
                        if verbose:
                            print('fam hit, info>%s<.' % info)
                            if verbose > 1:
                                print('%s' % inf.ret_fields())

            if rc != RC_OK and default_search:
                #
                # still no match, try for an overall default record.
                info = host_db.get(dppydb.default_to_node_name(), None)
                if verbose:
                    print('try uber default')
                if info:
                    info = (info,)
                    if verbose:
                        print('uber default hit.')
                        print('info>%s<' % info)
                    rc = RC_OK

    #dp_io.ctracef(2, 'rc: %s, tried >%s< for >%s<' % (rc, host, info_item))
    #
    # found the db entry, now get the requested info
    if rc == RC_OK:
        # find the item
        if dump_all_fields:
            if verbose:
                print('Dumping all fields')
            dump_all(info)
        else:
            for inf in info:
                try:
                    x = inf[info_item]
                    dumper.found(info_item=info_item, data=x)
                    raise SUCCESS
                except KeyError:
                    #dp_io.eprintf("YOPP!\n")
                    pass

    #
    # any successful lookup throws an exception, so only
    # failures make it here.
    #
    global num_failures
    num_failures = num_failures+1
    dumper.not_found(info_item=info_item, not_found_string=not_found_string)

host = None
domain = None
passed_domain = None
dump_all_fields = False
locale_search = True
domain_search = True
default_search = True
wildcard_match = True
import getopt

# dp_io.eprintf('argv: %s', sys.argv)
options, args = getopt.getopt(sys.argv[1:], 'h:d:vn:DLai:w')
for (o, v) in options:
    if o == '-d':
        domain = v
        continue
    if o == '-h':
        host = v
        continue
    if o == '-v':
        verbose = verbose + 1
        continue
    if o == '-n':
        not_found_strings.append(v)
        continue
    if o == '-D':
        default_search = not default_search
        continue
    if o == '-L':
        locale_search = not locale_search
        continue
    if o == '-a':
        dump_all_fields = not dump_all_fields
        continue
    if o == '-w':
        wildcard_match = not wildcard_match

    #
    # Allow query items to be given with -i <item>
    # This makes it easier to see correlation between
    # query items and defaults, e.g.:
    # -i boo -n no_boo_in_the_database
    if o == '-i':
        items.append(v)
        continue

dppydb.prep()
host_db = dppydb.load(wild='host_info', verbose=verbose)

full_host = os.uname()[1]
if not full_host:
    dp_io.eprintf('failed to determine full_host.\n')
    sys.exit(22)

if not host or not domain:
    try:
        i = str.index(full_host, '.')
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
    dp_io.eprintf('host>%s<\n', host)
    dp_io.eprintf('domain>%s<\n', domain)

if dump_all_fields:
    try:
        lookup_item('not really used')
    except Success_t:
        pass

dump_all_fields = None
not_found_index = 0
for item in items + args:
    try:
        if not_found_index >= len(not_found_strings):
            nfs = '-'
        else:
            nfs = not_found_strings[not_found_index]
        lookup_item(item, not_found_string=nfs,
                    locale_search=locale_search,
                    domain_search=domain_search,
                    default_search=default_search,
                    wildcard_match=wildcard_match,
                    dump_all_fields=dump_all_fields)
    except Success_t:
        pass

    not_found_index = not_found_index + 1

sys.exit(num_failures)
