#!/usr/bin/env python

import sys, os, types, re, string
import dp_utils, dp_io
opath = os.path
URL_regexp = re.compile("\s*URL:\s+(.*)$")

class Memoizable_c(object):
    def __init__(self, key, getter, *getter_args, **getter_kw_args):
        self.key = key
        self.getter = getter
        self.getter_args = getter_args
        self.getter_kw_args = getter_kw_args
        self.v_value = None
        self.v_set_p = False

    def set_p(self):
        return self.v_set_p

    def set(self, key, val):
        self.value = val
        self.set_p = True
        
    def val(self, key):
        if not self.set_p():
            if getter:
                self.v_value = getter(*self.getter_args, **self.getter_kw_args)
                self.set_p = True
        return (self.v_value, self.set_p())
    __call__ = val

class Memoizable_regexp_fields_c(Memoizable_c):
    def __init__(self, key, regexp):
        super(Memoizable_regexp_fields_c, self).__init__(key, self.getter)
        self.key = key
        self.regexp = regexp

    def parse_till_regexp_rl(self, regexp):
        cre = []                        # Closure(ish:-(
        def regexp_parser(line):
            return cre[0].search(line)
        if type(regexp) == types.StringType:
            cre[0] = re.compile(regexp)
        else:
            cre[0] = regexp
        self.readline_and_process(parser=regexp_parser)


    def getter(self, *args, **kw_args):
        pass
    
class Memoizable_cmd_response_c(Memoizable_regexp_fields_c):
    MEMO_KEY = "data"
    def __init__(self, command, *args, **kw_args):
        super(Svn_cmd_c, self).__init__(MEMO_KEY, self.read)
        self.command = command
        self.args = args
        self.file_obj = self.run()

    def run(self):
        self.file_obj = os.popen("svn %s %s" % self.command,
                                 string.join(self.args, " "))
        self.set(MEMO_KEY, self.read_all_lines)
            
    open = run                          # More file like.
    
    def read(self, n=0):
        self.self.file_obj.read(n)

    def readline(self, n=0):
        return self.file_obj.readline(n)

    def reader_process(self, reader, processor, n=0):
        while True:
            d = reader(n)
            if not d:
                break
            self.processor(d)          # Subclass worthy.

    def read_and_process(self, n=0, **kw_args):
        processor = kw_args.get("processor", self.reader_processor)
        processor(self.file_obj.read, processor=processor, n=n)

    def readline_and_process(self, n=0, **kw_args):
        processor = kw_args.get("processor", self.reader_processor)
        self.reader_processor(self.file_obj.readline, n=n,
                              processor=processor)

    def read_all_lines(self):
        self.lines = []
        self.readline_and_process(processor=self.lines.append)
    
    def close(self):
        self.file_obj.close()

class Svn_cmd_c(Memoizable_cmd_response_c):
    MEMO_KEY = "data"
    def __init__(self):
        pass

class Svn_regexp_field_c(Memoizable_c):
    def __init__(self, key, regexp):
        self.key = key
        self.regexp = regexp

    def value(self):
        pass
    

NODE_KIND = "node_kind"
class Svn_info_c(Svn_cmd_c):
    def __init__(self, *args, **kw_args):
        self.fields = {}

    def memoized(key):
        return self.fields.get(key)

    def memoize(key, val):
        self.fields[key] = val
        return val

    # E.g. Node Kind: file
    def node_kind(self):
        pass
        
        
class Modified_url(object):
    def __init__(self, orig_url, new_url="", error_message=None,
                 ostream=sys.stdout, estream=sys.stderr):
        self.orig_url = orig_url
        self.new_url = new_url
        self.error_message = error_message
        self.ostream = ostream
        self.estream = estream

    def new(self):
        return self.new_url
    def orig(self):
        return self.orig_url
    def emsg(self):
        return self.error_message

    def bad_p(self):
        return self.error_message or not self.new_url

    def pstream(self):
        if self.bad_p():
            return self.estream
        else:
            return self.ostream

    def pself(self):
        ps = self.pstream()
        ps.write("%s\n" % self)
        return ps
        
    def __str__(self):
        if self.error_message:
            return "error: %s" % (self.error_message, )
        elif not self.new_url:
            return "error: No new value."
        else:
            return self.new_url

    def __repr__(self):
        s = "%s --> %s" % (self.orig_url, self.new_url)
        if self.error_message:
            s += " (error: %s)" % (self.error_message,)
        return s

def get_url_from_file(file_obj_or_name):
    if type(file_obj_or_name) == types.StringType:
        opened_p = True
        file_obj = os.popen("svn info %s" % file_obj_or_name)
    else:
        file_obj = file_obj_or_name
        opened_p = False
    m = None
    while True:
        line = file_obj.readline()
        if not line:
            break
        line = line[:-1]
        m = URL_regexp.search(line)
        if m:
            break
    if opened_p:
        file_obj.read()   # Prevent broken pipe error.  Doesn't seem to work.
        file_obj.close()
    if m:
        return m.group(1)
    return None

def up_in_url_space(path_name, num_dotdots, dotdot_string):
    rp = os.path.realpath(os.path.expanduser(os.path.expandvars(path_name)))
    if not os.path.isdir(rp):
        emsg = "%s is not a directory;  Skipped." % rp
        u = None
    else:
        u = get_url_from_file(rp)
        if u:
            emsg = None
        else:
            emsg = "get_url_from_file(%s) failed." % (`rp`, )
    if u:
        u = dp_utils.dotdot_ify_url(u, num_dotdots, dotdot_string)
    return Modified_url(path_name, u, emsg)

def ups_in_url_space(path_names, num_dotdots, dotdot_string):
    return [ up_in_url_space(pn, num_dotdots, dotdot_string)
             for pn in path_names ]

# Up indicators: pure number, relative path (./) .., ...
# [0-9]+, -<sss>, [.]{3,} --> num-dotdots 1 + N-2
UP_INDICATOR_REGEXP = re.compile(
    "^(?P<all>" +
    "(?P<num_dots>[0-9]+)" + "|" +
    "(?P<dot_str>[.]{2,})" + "|" +
    "([+-](?P<str>.+))" +
    ")$")
def up_indicator_p(argv):
    return UP_INDICATOR_REGEXP.search(argv[1])
    
def up_indicator_match_to_num_dotdots(m):
    if m:
        if m.group("num_dots"):
            return eval(m.group("num_dots"))
        elif m.group("dot_str"):
            return len(m.group("dot_str")) - 1
        elif m.group("str"):
            return len(string.split(os.path.normpath(".."), opath.sep))
    return None

def up_indicator_to_num_dotdots(argv):
    return up_indicator_match_to_num_dotdots(up_indicator_p(argv))
    
def ups_in_url_space_argv(argv):
    """[up-indicator] directory-name...
.|..|..."""
    num_dotdots = 0
    dotdot_string = ""
    if len(argv) > 1 and len(argv[1]) > 0:
        del_it = True
        if argv[1][0] in string.digits:
            num_dotdots = eval(argv[1])
        elif up_indicator_p(argv):
            num_dotdots = up_indicator_to_num_dotdots(argv)
        elif argv[1][0] == '-':
            dotdot_string = argv[1][1:]
        else:
            del_it = False
        if del_it:
            del argv[1]
    if len(argv) == 1:
        args = (".",)
    else:
        args = argv[1:]
    # print "args:", args, ", num_dotdots:", num_dotdots, ", dotdot_string:", dotdot_string
    return ups_in_url_space(args, num_dotdots, dotdot_string)

def show_upped_urls(upped_urls, ostream=sys.stdout):
    for u in upped_urls:
        u.pself()

def show_upped_urls_argv(argv, ostream=sys.stdout):
    show_upped_urls(ups_in_url_space_argv(argv))

def file_type(path_or_url):
    svn_info = Svn_info_c(path_or_url)
    
    
if __name__ == "__main__":
    show_upped_urls_argv(sys.argv)
