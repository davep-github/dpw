#!/usr/bin/env python

#
# davep's standard Python file template.
# /home/davep/bin/templates/python-template.py
#

import os, sys, errno
import argparse
import random
import dp_io

debug_file = sys.stderr
verbose_file = sys.stderr
warning_file = sys.stderr

BROKEN_PIPE_RC = 1
IOERROR_RC = 1

class Replacer_base(object):
    """ Want to be able to replace things like l with [1,i,I].
    special_replacements are based on the idea of shell meta-characters.
    Some sites may get grumpy if they are fed these things.
    Are concatenated with replacements unless disable by a flag.
    at this time, index is unused but may be used by a looker-upper.
"""
    def __init__(self):

    def replacement(self):
        raise NotImplemented error

class Replacer_rand_list(Replacer_base):
    ### @todo XXX I think this isn't the correct use of super, even if it works.
    def __init__(self,
                 replacements,
                 special_replacements = [],
                 flags = [],
                 index=None):
        self.replacements = replacements
        self.special_replacements = special_replacements
        self.all_replacements = self.replacements + self.special_replacements
        # Precomputing this will save hours over the next few megayears.
        self.num_replacements = len(self.all_replacements)
        self.flags = flags
        self.index = index
        self.local_random = random.Random.randrange

    def replacement(self):
        raise NotImplemented error



#
# The -Ess- type (name of letter) replacements may be too obvious?
# Obvious is good for remembering, and -XX- may be a good password.
# Make the -<letter-name>- standard?  Use correct dictionary name, tho.
# Anything not found is unchanged.
# I know I have a hash with list as key.  But it's probably in elisp.
# Hence one char per entry.

Replacement_map = {
    ## Make the key a set/tuple/list if needed.
    "l": Replacer(["1", "i", "I"], ["|"]),
    "L": Replacer(["1", "i", "I", "!"], ["|", "!_"]),
    "1": Replacer(["l", "i", "I", "!"], ["|", "!_"]),
    "S": Replacer(["5",], ["-Ess-",]),
    "s": Replacer(["5",], ["-Ess-",]),
    "N": Replacer([], ["-en-", "-EN-", "|\|"]),
    "n": Replacer([], ["-en-", "-EN-", "|\|"]),
    "E": Replacer(['3'], ['-ee']),
    "e": Replacer(['3'], ['-ee']),
    ## @todo XXX have some way of adding the set of upper & lower case
    ## letters.  Like the hand-coded 'o', 'O'.  1 hr of coding to save some
    ## number of *milliseconds* in the years to come.
    "O": Replacer(['0', 'o', 'O'], ['-oh-']),
    "o": Replacer(['0', 'o', 'O'], ['-oh-']),
}


def repl_word(word):
    replacement_word = ""
    for ch in word:
        replacer_list = Replacement_map.get(ch, None)
        # if not found, identity.
        if replacer_list:
            # Why is reusing ch here so creepy?  Some older language taboo?
            ch = replacer_list.replacement()
        replacement_word = replacement_word + ch
    return replacement_word

#
# Perform arbitrary actions to process an argument within the argparse framework.
# e.g. class App_arg_action(argparse.Action):
# e.g.     def __call__(self, parser, namespace, values, option_string=None):
# e.g.         regexps = getattr(namespace, self.dest)
# e.g.         regexps.append(values)
# e.g.         setattr(namespace, self.dest, regexps)
# e.g.         setattr(namespace, "highlight_grep_matches_p", True) 

def main(argv):

    oparser = argparse.ArgumentParser()
    oparser.add_argument("--debug", "--dl",
                         dest="debug_level",
                         type=int,
                         default=-1,
                         help="Set debug level. Use with, e.g. "
                         "dp_io.cdebug(<n>, fmt [, ...])")
    oparser.add_argument("--verbose-level", "--vl",
                         dest="verbose_level",
                         type=int,
                         default=-1,
                         help="Set verbose/trace level. Use with, e.g. "
                         "dp_io.ctracef(<n>, fmt [, ...])")
    oparser.add_argument("-q", "--quiet",
                         dest="quiet_p",
                         default=False,
                         action="store_true",
                         help="Do not print informative messages.")
# e.g.     oparser.add_argument("--app-action", "--aa",
# e.g.                          dest="app_action_stuff", default=[],
# e.g.                          action=App_arg_action,
# e.g.                          help="Something normal actions can't handle.")

    # ...

    # For non-option args, first arg is name that goes into app_args.
    oparser.add_argument("words", nargs="*")

    app_args = oparser.parse_args()
    if app_args.quiet_p:
        print("I am being quiet.")
    if app_args.debug_level >= 0:
        dp_io.set_debug_level(app_args.debug_level, enable_debugging_p=True)
    if app_args.verbose_level > 0:
        dp_io.set_verbose_level(app_args.verbose_level, enable_debugging_p=True)
    words = app_args.words
    for word in words:
        r = repl_word(word)
        print("original>{}<, l33t>{}<".format(word, r))

if __name__ == "__main__":
    # try:... except: nice for filters.
    try:
        sys.exit(main(sys.argv))
    except IOError as e:
        # We're quite often a filter reading or writing to a pipe.
        if e.errno == errno.EPIPE:
            # Ya see, the colon looks like a broken pipe, heh, heh.
            # : |
            print(":Broken PIPE:", file=sys.stderr)
            sys.exit(BROKEN_PIPE_RC)
        print("IOError>%s<" % (e,), file=sys.stderr)
        sys.exit(IOERROR_RC)
