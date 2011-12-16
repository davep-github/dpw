#!/usr/bin/env python

import sys, os, string, re, pwd, getopt

entry_skel = '''e(
    kef='alias',
    dat={
    'email': """%s""",
    'name': """%s""",
    'alias': """%s""",
    })
'''

class Pwd_ent_t(object):
    def __init__(self, pwd_ent):
        self.user_name = pwd_ent[0]
        self.passwd = pwd_ent[1]
        self.uid = pwd_ent[2]
        self.gid = pwd_ent[3]
        self.full_name = pwd_ent[4]
        self.home_dir = pwd_ent[5]
        self.shell = pwd_ent[6]
        
def mk_pb_entry(out_fobg, full_name, email_addr, alias):
    e = entry_skel % (email_addr, full_name, alias)
    out_fobg.write(e)

def pwd_ent_to_pb(out_fobg, pwd_ent, domain):
    # Can we use these to filter out non humans?  Should we?
    #home_dir = pwd_ent[5]
    #shell = pwd_ent[6]
    # , seems to a sub-separator of the name field.  For, I think, other user
    # info.
    full_name = re.search("([^,]*)", pwd_ent.full_name)
    if full_name:
        full_name = full_name.group(1)
    if not full_name:
        full_name = pwd_ent.user_name
                          
    string.strip(pwd_ent.full_name, ",")
    email_addr = "%s@%s" % (pwd_ent.user_name, domain)
    # User name as alias.
    mk_pb_entry(out_fobg, full_name, email_addr, pwd_ent.user_name) 

def vanu_pred(pwd_ent):
    return not (pwd_ent.uid < 100 or pwd_ent.uid >= 64000)
    
def passwd_to_pb(out_fobg, domain, filter_pred=vanu_pred):
    for pwd_tuple in pwd.getpwall():
        pwd_ent = Pwd_ent_t(pwd_tuple)
        if vanu_pred(pwd_ent):
            pwd_ent_to_pb(out_fobg, pwd_ent, domain)
    
def main(argv):
    options, args = getopt.getopt(argv[1:], 'd:o:')
    out_fobj = sys.stdout
    domain = "YOUARENOWHERE"
    close_p = False
    for o, v in options:
        if o == '-d':
            domain = v
            continue
        if o == '-o':
            out_fobj = open(v, "w")
            close_p = True
            continue
    passwd_to_pb(out_fobj, domain)
    if close_p:
        out_fobj.close()

    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))

