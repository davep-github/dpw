#!/usr/bin/env python
# $Header: /usr/yokel/archive-cvsroot/davep/bin/file-mail.py,v 1.2 2001/08/02 07:30:08 davep Exp $

import os
import sys
import string
import getopt

inc_folder = '+inbox'
test_suffix = ''

destinations = {}
default_folder = '+pending'

show_cmd_f = 1
do_cmd_f = 1
do_inc_f = 0
verbose = 0
distrib_rules = '%s/.file-mail.rules.py' % os.environ['HOME']

#
# each contains a destination folder and a list of 
# (op, opargs) tuples
# op is a pick operator which is distributed across the opargs,
# opargs is a list of args to the op operator.
#
# Each arg[i] is a tuple: (op, opargs)
#
class rule:
    def __init__(self, destination, *args):
	# save the destination folder
	self.destination = destination
	self.op_list = []
	i = 0
	for i in args:
	    self.op_list.append(i)

def do_cmd(cmd, ok_responses=[0]):
	if show_cmd_f:
		print 'cmd:', cmd

	if do_cmd_f:
		rc = os.system(cmd)
		rc = rc >> 8
 		if not rc in ok_responses:
 			sys.stderr.write("%s failed: %d\n" % (cmd, rc));
 			sys.exit(rc)

#
# parse command line
#
options, args = getopt.getopt(sys.argv[1:], 'nf:x?htivr:')
for opt, val in options:
	#print "opt", opt, "val", val
	if opt == '-i':
	    do_inc_f = 1
	elif opt == '-n':
	    show_cmd_f = 1
	    do_cmd_f = 0
	elif opt == '-f':
	    inc_folder = val
            if inc_folder[0] != '+':
                inc_folder = '+' + inc_folder
	elif opt == '-t':
	    inc_folder = '+inc_tmp'
	    test_suffix = '_TEST'
	elif opt == '-v':
	    verbose = 1
	elif opt == '-r':
	    distrib_rules = val
	elif opt[1] in "x?h":
	    sys.stderr.write(
		"usage: distrib.py [-niqh?xt] [-f inbox_folder]\n");
	    sys.exit(1)
	elif opt == '-q':
	    show_cmd_f = 0

#
# rules is a list of rule objects
# initialize the list
try:
    exec open(distrib_rules)
except IOError:
    sys.stderr.write('cannot open rule file: %s\n' % distrib_rules)
    sys.exit(1)
except SyntaxError:
    sys.stderr.write('syntax error in rule file: %s\n' % distrib_rules)
    sys.exit(1)


#
# include new mail if requested
#
if do_inc_f:
    # let inc fail with rc of one, no messages to inc.
    do_cmd('inc %s' % inc_folder, [0, 1])

# pull the rules out one by one
for rule in rules:
    #	print 'rule', rule
    folder = rule.destination

    #
    # construct the pick command parameters from all of the
    # op and oplists.
    # Everything is or'd together
    ors = ''
    cmds = ''
    ands = ''
    for op, arglist in rule.op_list:
	#print 'op', op
	#print 'arglist', arglist
	# distribute the op over the args
	# joined with '-or'
	lb = ' -lbrace '
	rb = ''
	for arg in arglist:
	    cmds = cmds + ands + lb + ors +  op + ' ' + '"' + arg + '"'
	    ors = ' -or '
	    lb = ''
	    rb = ' -rbrace '
	    #print 'cmds', cmds, 'folder', folder
	
	ands = ' -and '
	ors = ''
	cmds = cmds + rb

    # use pick command to find matching messages
    # build a sequence of message numbers
    cmd = 'pick %s %s' % (inc_folder, cmds)
    if verbose:
	print '>>>>>cmd', cmd
    f = os.popen(cmd, 'r')
    seq = []
    while 2:
	tline = f.readline()
	if (not tline):
	    break
	if tline[-1] == '\n': 
	    tline = tline[:-1]
	if tline[0] == '0':
	    break
	seq.append(string.atoi(tline))
    f.close()
	
    # using the message number as a key, append the folder to
    # the list of destinations for this message,
    # this allows us to store messages in >1 folder.
    for seq_num in seq:
	try:
	    destinations[seq_num].append(folder)
	except KeyError:
	    destinations[seq_num] = [folder]

# for each message, store it in its list of destination folders
keys = destinations.keys()
keys.sort()
for msg_num in keys:
    #
    # if the default folder is not the only dest, then delete
    # it from the list of destinations.
    #
    dests = destinations[msg_num]
    if len(dests) > 1:
        try:
            dests.remove(default_folder)
        except ValueError:
            pass
        
    folder_list = string.joinfields(dests, ' ')
    #print msg_num, folder_list

    # show the user the details of the current message
    cmd = 'scan %d' % msg_num
    rc = os.system(cmd)
    if rc != 0:
        sys.stderr.write("%s failed: %d\n" % (cmd, rc));
        sys.exit(rc)

    # put the message in its new home
    cmd = 'refile %s %d' % (folder_list + test_suffix, msg_num)
    do_cmd(cmd)
