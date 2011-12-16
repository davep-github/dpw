#!/usr/bin/env python
#
# Use SSH to act like an FTP client for emacs' efs/ange-ftp package.
# Convert all ftp commands to ssh/scp equivalents.
# keep state in the client, since each command
# consists of one or more ssh/scp commands.
# 
# NB: we only support the subset of commands used by efs/ange-ftp
#

import string, time, sys, os, dp_io, stat, socket, popen2

dp_io.debug_on()
debug_file = open("/tmp/ftp-over-ssh.py.log", "w")
dp_io.debug_file(debug_file)

###############################################################
class State:
    def __init__(self):
        self.current_wd = "~"
        self.hash = 0
        self.hash_size = 1024
        # XXX for testing, some lazy defaults
        self.host = 'z08'
        self.user = 'davep'
        self.passwd = 'x'
        self.ls_output_file = None      # None --> stdout
        self.umask = 022

###############################################################
def find_full_host_name(host):
    full_host = socket.getfqdn(host)
    if string.find(full_host, '.') < 0:
        return None
    else:
        return full_host

###############################################################
def quote_cmd_for_shell(str):
    return str                          # XXX do this right!

###############################################################
def error_printer(rc, cmd, cmd_stdout, cmd_stderr):
    dp_io.debug('error printer, rc>%s<, out>%s<, err>%s<\n',
                rc, cmd_stdout, cmd_stderr)
    print '550 command [%s] failed, rc: %s.' % (cmd, rc)
    
###############################################################
def send_cmd(cmd, output_processor, error_processor):
    dp_io.debug('cmd>%s<\n', cmd)
    proc = popen2.Popen3(cmd, 1)
    std_strings = ['', '']
    fds = [(proc.fromchild, 0), (proc.childerr, 1)]
    while fds:
        #
        # read small chunks so sending proc doesn't block
        # writing to an unread stream while we block
        # reading the other stream
        for file, str_idx in fds:
            s = file.read(64)
            dp_io.debug('s>%s<', s)
            if not s:
                file.close()
                fds.remove((file, str_idx))
                break
            std_strings[str_idx] = std_strings[str_idx] + s

    cmd_stdout = std_strings[0]
    cmd_stderr = std_strings[1]

    # get the completion status
    rc = proc.wait()
    dp_io.debug("cmd rc>%s<\n", rc)
    if rc == 0:
        cmd_stdout = string.strip(cmd_stdout)
        if output_processor:
            output_processor(cmd_stdout)
        return 0
    else:
        # let the caller process the errors if desired
        if error_processor:
            error_processor(rc, cmd, cmd_stdout, cmd_stderr)
        else:
            # simple error indication as fallback
            print '550 command failed.'
        return -1

###############################################################
def ssh_cmd(cmd_str, output_processor, error_processor):
    cmd = 'ssh %s@%s "cd %s && umask %s && %s"' % (state.user,
                                                   state.host,
                                                   state.current_wd,
                                                   oct(state.umask),
                                                   cmd_str)

    return send_cmd(cmd, output_processor, error_processor)

###############################################################
def print_pwd(cmd_response):
    print '257 "%s" is current directory.' % (cmd_response)
    
###############################################################
def cmd_quote(argv):
    return process_argv(argv[1:], server_cmd_list)

###############################################################
def cmd_open(argv):
    state.host = argv[1]
    full_host = find_full_host_name(state.host)
    if not full_host:
        print 'ftp: %s: No address associated with hostname' % state.host
        return -1
    print """Connected to %s.
220 %s Pseudo FTP over SSH hack %s ready.""" % (full_host,
                                                full_host,
                                                time.ctime())
    return 0

###############################################################
def cmd_user(argv):
    state.user = argv[1]
    print """331 Password required for %s""" % (state.user)
    return 0

###############################################################
def cmd_pass(argv):
    state.passwd = argv[1]
    print """230 User %s logged in.""" % (state.user)
    return 0

###############################################################
def cmd_hash(argv):
    state.hash = not state.hash
    if state.hash:
        print 'Hash mark printing on (%d bytes/hash mark).' % state.hash_size
    else:
        print 'Hash mark printing off.'
    return 0

###############################################################
def cmd_pwd(argv):
    return ssh_cmd("pwd", print_pwd, error_printer)

###############################################################
def cwd_handler(cmd_response):
    dp_io.debug('cwd_handler, cmd_resp>%s<\n', cmd_response)
    state.current_wd = cmd_response
    print """250 CWD command successful."""
    
###############################################################
def cmd_cwd(argv):
    return ssh_cmd("cd %s && pwd" % argv[1], cwd_handler, error_printer)

###############################################################
def ls_handler(cmd_response):
    if state.ls_output_file == None:
        print cmd_response
    else:
        file = open(state.ls_output_file, "w")
        file.write(cmd_response + "\n")
        file.close()

    print '150 Opening ASCII mode data connection for /bin/ls.'
    print '226 Transfer complete.'
 
###############################################################
def cmd_ls(argv):
    avlen = len(argv)
    if avlen > 1:
        opts = ' ' + argv[1]
        if avlen > 2:
            state.ls_output_file = argv[2]
        else:
            state.ls_output_file = None
    else:
        opts = ''

    return ssh_cmd("ls%s" % opts, ls_handler, error_printer)

###############################################################
def echo_response(cmd_response):
    dp_io.debug('cmd_resp>%s<\n', cmd_response)

xfer_time = 22
###############################################################
def get_put_handler(cmd_response, filename, xfer_dir):

    size = os.stat(filename)[stat.ST_SIZE]

    # fake the hashes here...
    if state.hash:
        # freebsd ftp clien does not seem to round.
        num_hashes = (size) / state.hash_size
        print "#" * num_hashes

    print '%d bytes %s in %d seconds (%f KB/s)' % (size,
                                                   xfer_dir,
                                                   xfer_time,
                                                   float(size >> 10)/xfer_time)
    print '226 Transfer complete.'

###############################################################
def get_handler(cmd_response):
    get_put_handler(cmd_response, state.dest, 'received')

###############################################################
def put_handler(cmd_response):
    get_put_handler(cmd_response, state.src, 'sent')
    
###############################################################
def cmd_get(argv):
    # get src dest
    if len(argv) < 3:
        state.dest = argv[1]
    else:
        state.dest = argv[2]
    state.src = argv[1]

    print '200 PORT command successful.'
    print '150 Opening BINARY mode data connection for', state.src

    #     there               here
    # get /udir/davep/.bashrc /tmp/davep/efscbIXjh
    cmd = 'scp %s:%s %s' % (state.host, state.src, state.dest)
    return send_cmd(cmd, get_handler, error_printer)

###############################################################
def cmd_put(argv):
    # XXX we need to do a chmod on the dest file to
    # propate the umask value to the server.
    
    # put src dest
    if len(argv) < 3:
        state.dest = argv[1]
    else:
        state.dest = argv[2]
    state.src = argv[1]

    print '200 PORT command successful.'
    print '150 Opening BINARY mode data connection for', state.dest
    
    # 0   1                    [2]
    # put here                 there
    # put /tmp/davep/efscbIXjh /udir/davep/.bashrc
    cmd = 'scp %s %s:%s' % (state.src, state.host, state.dest)
    return send_cmd(cmd, put_handler, error_printer)

def print_response(cmd_response):
    print cmd_response
    
###############################################################
def cmd_mdtm(argv):

    perl_script = """(\$dev, \$ino, \$mode, \$nlink, \$uid, \$gid, \$rdev, \$size,\$atime, \$mtime, \$ctime, \$blksize, \$blocks)=stat(\$ARGV[0]);(\$sec,\$min,\$hour,\$mday,\$mon,\$year,\$wday,\$yday,\$isdst)=localtime(\$mtime);printf(\\"213 %04d%02d%02d%02d%02d%02d\\n\\", \$year+1900, \$mon, \$mday, \$hour, \$min, \$sec);"""
    
    cmd = '''perl -e '%s' %s''' % (perl_script, argv[1])
    #dp_io.debug("cmd>%s<\n", cmd)
    return ssh_cmd(cmd, print_response, error_printer)

###############################################################
def cmd_type(argv):
    return process_argv(argv[1:], client_cmd_list)

###############################################################
def cmd_image(argv):
    # we're always in bin mode
    print '200 Type set to I.'
    return 0

###############################################################
def cmd_site(argv):
    return process_argv(argv[1:], site_cmd_list)

###############################################################
def cmd_umask(argv):
    old = state.umask
    state.umask = eval(argv[1])
    print '200 UMASK set to %s (was %s)' % (oct(state.umask),
                                            oct(old))

    return 0

###############################################################
def cmd_idle(argv):
    # complete fakery
    # use a huge value, since we always timeout (no real connection)
    # we may as well pretend we never timeout
    timeout=24*60*60                    # one day
    print '200 Current IDLE time limit is %s seconds; max %d' % (timeout,
                                                                 timeout)
    return 0

###############################################################
def multi_line_response(code, id, text):
    sys.stdout.write('%03d-' % code)
    leader = ''
    for line in string.split(text, '\n'):
        print '%s%s' % (leader, line)
        leader = ' '
    if id:
        id = "(end of '%s')" % id
    else:
        id = ''
    print '%03d  %s' % (code, id)
    
###############################################################
def cmd_exec(argv):
    cmd = string.join(argv[1:], ' ')
    multi_line_response(200, cmd, cmd)
    return 0

###############################################################
def rnfr_handler(cmd_response):
    dp_io.debug('rf>%s<, resp>%s<\n', state.rnfr_file, cmd_response)
    if state.rnfr_file == cmd_response:
        print '350 File exists, ready for destination name'
    else:
        print '550 %s: No such file or directory.' % state.rnfr_file

###############################################################
def cmd_rnfr(argv):
    state.rnfr_file = argv[1]
    return ssh_cmd("ls %s" % argv[1], rnfr_handler, error_printer)

###############################################################
def cmd_syst(argv):
    # try a uname command --> unix
    if ssh_cmd('uname', None, None) == 0:
        s = 'UNIX Type: L8'
    else:
        s = 'UNKNOWN'

    print '215', s
    return 0

###############################################################
def delete_handler(cmd_response):
    print '250 DELE command successful.'

###############################################################
def cmd_delete(argv):
    ssh_cmd('rm %s' % argv[1], delete_handler, error_printer)

###############################################################
def rename_handler(cmd_response):
    print '250 RNTO command successful.'
    
###############################################################
def cmd_rename(argv):
    from_name = argv[1]
    to_name = argv[2]

    # ftp seems to do an rnfr and then a rnto
    rc = cmd_rnfr(('rnfr', from_name))
    if rc == 0:
        return ssh_cmd('mv %s %s' % (from_name, to_name),
                       rename_handler, error_printer)
    else:
        return rc
    
###############################################################
def process_argv(argv, cmd_list):
    try:
        cmd = cmd_list[string.lower(argv[0])]
    except KeyError:
        dp_io.eprintf("?Invalid command.\n")
        return -1

    return cmd(argv)
    
###############################################################
def process_line(argv, cmd_list):
    dp_io.debug("process_line, argv>%s<\n", argv)
    dp_io.debug("process_line, x>%s<\n", x)
    argv = string.split(x)
    dp_io.debug("process_line, post split, argv>%s<\n", argv)
    
    for i in range(1, len(argv)):
        if argv[i][0] == '"':
            argv[i] = eval(argv[i])
    return process_argv(argv, cmd_list)

site_cmd_list = {
    'umask': cmd_umask,
    'idle': cmd_idle,
    'exec': cmd_exec}

#
# some of these are actually server commands, accessed
# w/the quote command, but we go ahead and allow them to
# be client commands, too, so we don't need to duplicate
# them in two tables.
# So the server_cmd_list is just the client_cmd_list
#
client_cmd_list = {
    'quote': cmd_quote,
    'open': cmd_open,
    'user': cmd_user,
    'pass': cmd_pass,
    'hash': cmd_hash,
    'pwd': cmd_pwd,
    'cwd': cmd_cwd,
    'ls': cmd_ls,
    'get': cmd_get,
    'put': cmd_put,
    'mdtm': cmd_mdtm,
    'type': cmd_type,
    'image': cmd_image,
    'bin': cmd_image,
    'site': cmd_site,
    'rnfr': cmd_rnfr,
    'syst': cmd_syst,
    'delete': cmd_delete,
    'rename': cmd_rename}

# until any differences appear
server_cmd_list = client_cmd_list

# give us cheesy global access w/out global statements.
state = State()

welcome = "davep's ftp over ssh emulator\n\n"
sys.stdout.write(welcome)
dp_io.debug("davep's ftp over ssh emulator\n\n")
dp_io.debug("argv>%s<\n", sys.argv)

try:
    while 1:
        dp_io.debug("writing promt\n")
        sys.stdout.write("ftp> ")
        dp_io.debug("wrote prompt, reading line\n")
        x = sys.stdin.readline()
        dp_io.debug("read line, x>%s<\n", x)
        if not x:
            break

        dp_io.debug("x>%s<\n", x)
        x = string.strip(x)
        if not x:
            continue

        rc = process_line(x, client_cmd_list)
#        if rc != 0:
#            print '550 %s failed.' % x

        
except Exception, e:
    dp_io.eprintf("ftp-over-ssh.py died >%s<", e)
    dp_io.debug("ftp-over-ssh.py died >%s<", e)
    
