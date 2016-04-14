#rc_file = './.pyshrc'
#try:
#    execfile(rc_file, globals())
## except IOError, e:
##     print "(type(e): %s)e: %s" % (type(e), e)
##     print "e.__dict__: %s" % (e.__dict__,)
##     print 'source: Cannot open>%s<' % rc_file


import sys
import os
import rlcompleter, readline
import string, re, atexit, types, math
import dp_io
from dp_utils import *

"""pyshrc.py -- evaluated by pysh to create a standard and useful
environment."""

HIST_MAX = 5000
Last_rc_args = ()

########################################################################
#
########################################################################
def eprintf(fmt, *args):
    if args:
        fmt = fmt % args
    sys.stderr.write('%s' % fmt)

try:
    import pydoc
except:
    eprintf('Could not import pydoc.')
        
########################################################################
#
########################################################################
def writehistory(hist_file):
    """writehistory()
Write out the history file"""
    if hist_file:
        readline.write_history_file(hist_file)
        

########################################################################
#
########################################################################
def locate_rc_file(name, path=None):
    """locate_rc_file(name, path=None)
locate an rc file in a standard and useful manner:
1) see of rc_file has an identifying envvar: [.]rc_file --> RC_FILE
2) search path or (cwd and home)"""
    #
    # try an environ var naming the rc file
    #
    evar = string.upper(name)
    if evar[0] == '.':
        evar = evar[1:]
    evalue = os.environ.get(evar)
    if evalue:
        return (evalue)
    
    if path == None:
        path = (os.getcwd(), os.environ.get('HOME'))
        
    for place in path:
        if not place:
            continue
        place = os.path.normpath(place + '/' + name)
        if os.path.isfile(place):
            return place
    return None

########################################################################
#
########################################################################
def readline_stuff(prefix='.pysh'):
    """Initialize the readline system"""
    readline.parse_and_bind('tab: complete')

    initfile = locate_rc_file(prefix + 'inputrc')
    try:
        readline.read_init_file(initfile)
    except IOError:
        pass

    hist_file = locate_rc_file(prefix + 'hist')
    if hist_file:
        try:
            readline.read_history_file(hist_file)
            readline.set_history_length(HIST_MAX)
            atexit.register(lambda f=hist_file: readline.write_history_file(f))
        except IOError:
            pass
    del initfile

########################################################################
#
########################################################################
def source(*args):
    """source(*args)
Execute a python script or scripts in the global namespace.
No args says to used the last set of args"""
    global Last_rc_args
    if not args:
        args = Last_rc_args
    for file in args:
        try:
            execfile(file, globals())
        except IOError:
            eprintf('source: Cannot open>%s<\n', file)

########################################################################
#
########################################################################
def dexl(*args):
    """convert list of ints or strings containing C-type ints to decimal.
Basically massage the input and eval it.
"""
    for i in args:
        if type(i) == types.StringType:
            ## Remove commas; they make numbers more readable.
            ## Don't enforce any kind of grouping
            i = i.replace(",", "")
            # Oh, hell, let 'em use dots, too.
            i = i.replace(".", "")
            i = eval(i)
        print "%d" % (i,)

########################################################################
#
########################################################################
def hexl(*args):
    """convert list of ints or strings containing C-type ints to hex.
Basically massage the input and eval it.
"""
    for i in args:
        if type(i) == types.StringType:
            ## Remove commas; they make numbers more readable.
            ## Don't enforce any kind of grouping
            i = i.replace(",", "")
            # Oh, hell, let 'em use dots, too. Silly Europeans.
            i = i.replace(".", "")
            i = eval(i)
        print hex(i)

########################################################################
# awaaaay we go!
########################################################################

readline_stuff()

#print 'pysh ready.'
