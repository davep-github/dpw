""" User configuration file for IPython

This is a more flexible and safe way to configure ipython than *rc files
(ipythonrc, ipythonrc-pysh etc.)

This file is always imported on ipython startup. You can import the
ipython extensions you need here (see IPython/Extensions directory).

Feel free to edit this file to customize your ipython experience.

Note that as such this file does nothing, for backwards compatibility.
Consult e.g. file 'ipy_profile_sh.py' for an example of the things 
you can do here.

See http://ipython.scipy.org/moin/IpythonExtensionApi for detailed
description on what you could do here.
"""

# Most of your config files and extensions will probably start with this import

import IPython.ipapi
ip = IPython.ipapi.get()

# You probably want to uncomment this if you did %upgrade -nolegacy
# import ipy_defaults    

import os

def main():

    # uncomment if you want to get ipython -p sh behaviour
    # without having to use command line switches  
    # import ipy_profile_sh

    # Configure your favourite editor?
    # Good idea e.g. for %edit os.path.isfile

    #import ipy_editors

    # Choose one of these:

    #ipy_editors.scite()
    #ipy_editors.scite('c:/opt/scite/scite.exe')
    #ipy_editors.komodo()
    #ipy_editors.idle()
    # ... or many others, try 'ipy_editors??' after import to see them

    # Or roll your own:
    #ipy_editors.install_editor("c:/opt/jed +$line $file")


    o = ip.options
    # An example on how to set options
    o.autocall = 1
    o.system_verbose = 0
    o.autoindent = 1
    o.automagic = 1
    o.cache_size = 5555
    o.classic = 0
    o.colors = 'LightBG'
    o.color_info = 1
    o.confirm_exit = 1
    o.deep_reload = 0
    o.editor = 0
    o.log = 0
    o.logfile = ''
    o.banner = 1
    o.messages = 1
    o.pdb = 1
    o.pprint = 1
    o.readline = 1
    o.screen_length = 0
    import_mods(("os", "sys", "string", "re"))
    #execf('~/_ipython/ns.py')


    # -- prompt
    # A different, more compact set of prompts from the default ones, that
    # always show your current location in the filesystem:

    #o.prompt_in1 = r'\C_LightBlue[\C_LightCyan\Y2\C_LightBlue]\C_Normal\n\C_Green|\#>'
    #o.prompt_in2 = r'.\D: '
    #o.prompt_out = r'[\#] '

    # Try one of these color settings if you can't read the text easily
    # autoexec is a list of IPython commands to execute on startup
    #o.autoexec.append('%colors LightBG')
    #o.autoexec.append('%colors NoColor')
    #o.autoexec.append('%colors Linux')

    # for sane integer division that converts to float (1/2 == 0.5)
    o.autoexec.append('from __future__ import division')

    # For %tasks and %kill
    import jobctrl 

    # For autoreloading of modules (%autoreload, %aimport)    
    import ipy_autoreload

    # For winpdb support (%wdb)
    #import ipy_winpdb

    # For bzr completer, requires bzrlib (the python installation of bzr)
    #ip.load('ipy_bzr')

    # Tab completer that is not quite so picky (i.e. 
    # "foo".<TAB> and str(2).<TAB> will work). Complete 
    # at your own risk!
    import ipy_greedycompleter

    # To get to the readline object inside ipython, try this:
    # import IPython.rlineimpl as readline
    # If you are on Linux, you may be annoyed by
    # "Display all N possibilities? (y or n)" on tab completion,
    # as well as the paging through "more". Uncomment the following
    # lines to disable that behaviour
    import readline
    readline.parse_and_bind('set completion-query-items 1000')
    readline.parse_and_bind('set page-completions no')
    # This forces readline to automatically print the above list when tab
    # completion is set to 'complete'. You can still get this list manually
    # by using the key bound to 'possible-completions' (Control-l by default)
    # or by hitting TAB twice. Turning this on makes the printing happen at
    # the first TAB.
    readline.parse_and_bind('set show-all-if-ambiguous on')
    readline.parse_and_bind("'tab:' complete")
    readline.parse_and_bind("\C-i: complete")
    readline.parse_and_bind("\C-l: possible-completions")
    # If you have TAB set to complete names, you can rebind any key
    # (Control-o by default) to insert a true TAB character.
    readline.parse_and_bind("\C-o: tab-insert")

    # These commands allow you to indent/unindent easily, with the 4-space
    # convention of the Python coding standards.  Since IPython's internal
    # auto-indent system also uses 4 spaces, you should not change the number of
    # spaces in the code below.
    readline.parse_and_bind("\M-i: '    '")
    readline.parse_and_bind("\M-o: '\d\d\d\d'")
    readline.parse_and_bind("\M-I: '\d\d\d\d'")
    # Bindings for incremental searches in the history. These searches use
    # the string typed so far on the command line and search anything in the
    # previous input history containing them.
    readline.parse_and_bind("\C-r: reverse-search-history")
    readline.parse_and_bind("\C-s: forward-search-history")
    # Bindings for completing the current line in the history of previous
    # commands. This allows you to recall any previous command by typing its
    # first few letters and hitting Control-p, bypassing all intermediate
    # commands which may be in the history (much faster than hitting up-arrow
    # 50 times!)
    readline.parse_and_bind("\C-p: history-search-backward")
    readline.parse_and_bind("\C-n: history-search-forward")


    # !<@todo XXX I don't know how to do (ii) and (iii) now.
    # (ii) readline_remove_delims: a string of characters to be removed from the
    # default word-delimiters list used by readline, so that completions may be
    # performed on strings which contain them.
    #readline_remove_delims '"-/~
    #"' -- just to fix emacs coloring which gets confused by unmatched quotes.

    # (iii) readline_merge_completions: whether to merge the result of all
    # possible completions or not.  If true, IPython will complete filenames,
    # python names and aliases and return all possible completions.  If you
    # set it to false, each completer is used at a time, and only if it
    # doesn't return any completions is the next one used.  The default order
    # is: [python_matches, file_matches, alias_matches]
    #readline_merge_completions 1


# some config helper functions you can use
def import_all(mod_list):
    """ Usage: import_these("mod"[, "mod"...]) """
    for m in mod_list:
        ip.ex("from %s import *" % m)

def import_mods(mod_list):
    """ Usage: import_mods("mod"[, "mod"...]) """
    for m in mod_list:
        ip.ex("import %s" % m)

def execf(fname):
    """ Execute a file in user namespace """
    ip.ex('execfile("%s")' % os.path.expanduser(fname))

main()
