#!/usr/bin/env python

import sys, os

class Not_confirmed_c(Exception):
    def __init__(self, fmt, *args):
        self.message = fmt % args

class Oddity_list_c(object):
    def __init__(self):
        self.items = []

    def append(self, o):
        self.items.append(o)

    def replace_last(self, new_o):
        i = len(self.items) - 1
        self.items[i] = new_o

    def last_item(self):
        return len(self.items) - 1

    def extend_last(self, *args, **kw_args):
        self.last_item.extend(*args, **kw_args)

    def __str__(self):
        return "<Oddity_list_c/items:%s/>" % (self.items,)


class Oddity_c(object):
    def __init__(self, fmt, *args, **kw_args):
        self.def_reply = string.lower(kw_args.get("def_reply", "n"))
        self.mk_reply_prompt()
        self.oddity = fmt % args

    def mk_reply_prompt(self):
        if self.def_reply == "n":
            yn = ("y", "N")
        else:
            yn = ("Y", "n")
        self.reply_prompt = "%s/%s" % (yn[0], yn[1])
        return self.reply_prompt

    def confirmed_p(self, reply):
        return dp_utils.any_substring(reply, "yes")

    def extend(self, fmt, *args, **kw_args):
        sep = kw_args.get("sep", "\n")
        extension = fmt % args
        self.oddity += sep + extension
        return self

    def __iter__(self):
        return self.items.__iter__()

    def confirm(self):
        self.fprintf("\nContinue[%s]? ", self.mk_reply_prompt())
        reply = string.lower(istream.readline())
        return self.confirmed_p(reply)
        
class State_c(object):
    def __init__(self, ostream=sys.stdout, istream=sys.stdin):
        # Set this if anything unexpected.
        # We'll ask for confirmation.
        self.confirm_p = True
        self.oddities = Oddity_list_c()
        self.last_oddity = None

    def oddity(self, fmt, *args, **kw_args):
        self.last_oddity = Oddity_c(fmt, args, kw_args)
        self.oddities.append(self.last_oddity)
    warn = oddity
        
    def extend_oddity(self, fmt, *args, **kw_args):
        self.oddities.extend_last(fmt, *args, **kw_args)

    def printf(self, fmt, *args):
        dp_io.fprintf(self.ostream, fmt, *args)

    def confirm_all(self):
        if self.confirm_p:
            if len(self.warnings) > 1:
                plural = "ies"
            else:
                plural = "y"
            self.fprintf(self.ostream,
                         "Oddit%s encountered, please confirm operation",
                         plural)
            for o in self.oddities:
                try:
                    self.oddities
                except:
                    raise
        else:
            return True

#def main(args):
#    pass

#if __name__ == "__main__":
#    main(sys.argv)


