#!/usr/local/bin/python

import sys
import getopt
import string
import dp_io
from types import *

def opts_intval(options, num_str, default):
    if num_str[0] not in '0123456789-':
        dp_io.eprintf("opts_intval(): non numeric `%s'\n", num_str)
        sys.exit(99)
        
    return eval(num_str)

def opts_add_to_list(options, new_element, default):
    options.list.append(new_element)
    return options.list

class Option:
    def __init__(self, ch, field, set, default, help='too lazy'):
        self.ch = ch
        self.field = field
        self.set = set
        self.default = default
        self.help = help
        self.list = []

    def get_default(self):
        if type(self.default) == FunctionType:
            v = self.default()
        else:
            v = self.default
        return v

    def get_def_help(self):
        if type(self.default) == FunctionType:
            h = '%s()=%s' % (self.default.__name__, self.get_default())
        else:
            h = self.get_default()
        return h

    def get_help(self):
        set_help = self.get_set_help()
        def_help = self.get_def_help()
        args = self.get_arg_str()
        if len(self.ch) > 1:
            opt_name = '[' + str.join(self.ch, '|') + ']'
        else:
            opt_name = self.ch
        return '-%s %s\t%s\n\t[default=%s, set=%s]' % \
               (opt_name,
                args,
                self.help,
                def_help,
                set_help)

    def __str__(self):
        return ("ch>{}<, field>{}<, set>{}<, def>{}<, help>{}<".format(self.ch,
                self.field, self.set, self.default, self.help))

class FlagOption(Option):
    def __init__(self, ch, field, set, default, help='too lazy(flag)'):
        Option.__init__(self, ch, field, set, default, help)

    def get_set(self, arg = None):
        if type(self.set) == FunctionType:
            v = self.set()
        else:
            v = self.set
        return v

    def get_name(self):
        return self.ch

    def get_arg_str(self):
        return ''

    def get_set_help(self):
        if type(self.set) == FunctionType:
            set_help = '%s()=%s' % (self.set.__name__, self.get_set())
        else:
            set_help = self.get_set()
        return set_help

class ArgOption(Option):
    def __init__(self, ch, field, set, default, help='too lazy(arg)'):
        Option.__init__(self, ch, field, set, default, help)
        print("ArgOption>{}<".format(Option.__str__(self)))

    def get_set(self, arg):
        if type(self.set) == FunctionType:
            v = self.set(self, arg, self.default)
        else:
            v = arg
        return v

    def get_name(self):
        ret = str.join(self.ch, ':')
        return ret

    def get_arg_str(self):
        return 'arg '
    
    def get_set_help(self):
        if type(self.set) == FunctionType:
            set_help = '%s(arg)' % (self.set.__name__,)
        else:
            set_help = 'arg'
        return set_help

class Options:
    def __init__(self, argv, opts=[], usage=None):
        import getopt

        self._opts = opts
        print("opts>{}<".format(opts))
        options = ''
        # make getopt list from opt lists
        options = [opt.get_name() for opt in opts]
        print("options>{}<".format(options))
        tlist = [ch[0] for ch in options]
        print("tlist>{}<".format(tlist))
        for opt in tlist:
            print("opt>{}<".format(opt))
            if tlist.count(opt) > 1:
                print(("%s: Option `%s' is duplicated" % (__name__, opt)))
                sys.exit(3)

        options = str.join(options, '')

        # set defaults from lists
        for o in opts:
            v = o.get_default()
            try:
                getattr(self, o.field)
                dp_io.eprintf("WARNING: The field `%s' already exists in this Options object.\n", o.field)
                dp_io.eprintf(''' your option name may be colliding
 with an existing function or variable of the Options class''')

            except AttributeError:
                pass
            setattr(self, o.field, v)

        try:
            options, self.args = getopt.getopt(argv[1:], options)
        except getopt.GetoptError as e:
            dp_io.eprintf('getopt failed: %s\n', e)
            if usage:
                usage()
            sys.exit(99)

        for opt, arg in options:
            print("opt>{}<, arg>{}<".format(opt, arg))
            for o in opts:
                if opt[1] in o.ch:
                    v = o.get_set(arg)
                    setattr(self, o.field, v)
                    continue

    def dump(self):
        output = []
        output.append('Options contains:\n')
        for k in dir(self):
            if str.find(k, '_') != 0:
                output.append('  %s>%s<\n' % (k, getattr(self, k)))
        return str.join(output, '')

    show = dump

    def __str__(self):
        return self.dump()

    def help(self, opts=[]):
        # print 'in help'
        output = []
        if opts == []:
            opts = self._opts
        # print 'opts:', opts
        for opt in opts:
            # print 'opt:', opt
            output.append('%s, current: %s\n\n' % (opt.get_help(),
                                                   getattr(self, opt.field)))
        return str.join(output, '')


def opts_help(opts):
    """Cannot show current values."""
    output = []
    for opt in opts:
        output.append('%s\n' % (opt.get_help()))
    return str.join(output, '\n')
