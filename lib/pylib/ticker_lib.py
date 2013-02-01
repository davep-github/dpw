#!/usr/bin/env python

import sys, dp_utils, types, re

def Ticker_printf(ticker, fmt, *args):
    from dp_io import fprintf
    fprintf(ticker.ostream, fmt, *args)

class Ticker_t(object):
    def __init__(self, tick_interval, increment=1, init_string="counting: ",
                 comma=", ", init_count=0, ostream=sys.stdout, forward=False,
                 unit_name="line",
                 printor=Ticker_printf,
                 grand_total_p=True):
        self.tick_interval = tick_interval
        self.increment = increment
        self.init_string = init_string
        self.unit_name = unit_name
        self.comma = comma
        self.init_count = init_count
        self.reset_counter()
        self.printor = printor
        self.ostream = ostream
        self.grand_total_p = grand_total_p

    def twiddling_p(self):
        return False

    def reset_counter(self):
        self.counter = self.init_count
        self.sep_string = self.init_string

    def make_tick(self, tick=None, call_tick=None):
        if not tick:
            tick=call_tick
        #print "self.sep_string>%s<, tick>%s<\n" % (self.sep_string, tick)
        self.printor(self, "%s%s", self.sep_string, tick)
        self.sep_string = self.comma

    def fini(self, force_grand_total_p=False):
        if force_grand_total_p or self.grand_total_p:
            print "\nTotal:", self.counter, dp_utils.pluralize(self.unit_name,
                                                               self.counter)

    def tick_not_ready(self):
        pass

    def __call__(self, reset_counter=False, set_n=False,
                 increment=None, tick=None):
        if reset_counter is not False:
            self.reset_counter()
        if set_n is not False:
            self.tick_interval = set_n
        if self.tick_interval is not None:
            if self.counter % self.tick_interval == 0:
                self.make_tick(tick=tick, call_tick=self.counter)
            else:
                self.tick_not_ready()
            self.counter += increment or self.increment


class Char_ticker_t(Ticker_t):
    def __init__(self, tick_interval, tick_char='.', increment=1,
                 init_string="", comma="", init_count=0, ostream=sys.stdout,
                 unit_name="line",
                 printor=Ticker_printf):
        super(Char_ticker_t, self).__init__(tick_interval=tick_interval,
                                            increment=increment,
                                            init_string=init_string,
                                            comma=comma,
                                            init_count=init_count,
                                            ostream=ostream,
                                            unit_name=unit_name,
                                            printor=printor)
        self.tick_char = tick_char

    def make_tick(self, *args, **keys):
        if not keys.get('tick'):
            keys['tick'] = self.tick_char
        super(Char_ticker_t, self).make_tick(*args, **keys)


PREDEF_TWIDDLES = {
"twiddle1": ("(twiddle1|1|bars|lines|bsd|portage|x)", "|/-\\|/-\\"),
"twiddle2": ("(twiddle2|2|[O0o.o0]|Os|0s|os|.s|os)", "O0o.o0"),
"twiddle3": ("(twiddle3|3|[_=-])", "_-=-"),
"twiddle4": ("(twiddle4|parens)", ["()", "(.)", "(o)", "(.)",
                                   "[]", "[.]", "[o]", "[.]"]),
}
TWIDDLE_NAMES = PREDEF_TWIDDLES.keys()

def Twiddle_twiddles(ostream=sys.stdout):
    i = 0
    keys = TWIDDLE_NAMES
    keys.sort()
    print >>ostream, "Use index number or match regexp to select twiddle:"
    for key in TWIDDLE_NAMES:
        print >>ostream, "d:", i, "name:", key, "twids:", PREDEF_TWIDDLES[key]
        i += 1

def nth_twiddle(n):
    #print "n:", n
    if type(n) == type(0):
        # select by number
        # Allow -x to ask for a list and exit.
        if n < 0:
            Twiddle_twiddles()
            sys.exit(0)
        twiddle_name = "twiddle" + str(n)
    else:
        # select by name
        twiddle_name = n
    for name in PREDEF_TWIDDLES:
        twid_info = PREDEF_TWIDDLES[name]
        m = re.search(twid_info[0], twiddle_name)
        if m:
            return twid_info[1]
    raise DP_UTILS_RT_Exception("""nth(%s) twiddle, `%s', cannot be found.
Can I interest you in any of these other fine twiddles?
%s\n""", n, twiddle_name, PREDEF_TWIDDLES)

class Twiddle_ticker_t(Ticker_t):
    def __init__(self, tick_interval, twiddle_chars=2,
                 increment=1, init_string="", ostream=sys.stdout,
                 unit_name="line",
                 comma="", init_count=0, printor=Ticker_printf):
        super(Twiddle_ticker_t, self).__init__(tick_interval=tick_interval,
                                               increment=increment,
                                               init_string=init_string,
                                               comma=comma,
                                               ostream=ostream,
                                               init_count=init_count,
                                               unit_name=unit_name,
                                               printor=printor)
###        print "twiddle_chars>%s<, type(twiddle_chars): %s" % (twiddle_chars, type(twiddle_chars))
        if (type(twiddle_chars) == types.IntType):
            self.twiddle_chars = nth_twiddle(int(twiddle_chars))
        elif type(twiddle_chars) in (types.ListType, types.TupleType):
            # Mnemonic, [] --> indexing. {} might be better, but not as
            # succinct.
            self.twiddle_chars = nth_twiddle(twiddle_chars[0])
        elif type(twiddle_chars) == types.StringType:
            if len(twiddle_chars) == 1:
                self.twiddle_chars = nth_twiddle(twiddle_chars[0])
            else:
                self.twiddle_chars = twiddle_chars
        else:
            raise DP_UTILS_RT_Exception("unsupported twiddle type: %s, %s",
                                        twiddle_chars, type(twiddle_chars))


    def twiddling_p(self):
        return True

    def reset_counter(self):
        self.bs = ''
        super(Twiddle_ticker_t, self).reset_counter()

    def make_tick(self, *args, **keys):
        if not keys.get('tick'):
            # e.g. |..../....-....\....|..../....-....\....|
            twiddle_index = (self.counter/self.tick_interval) \
                            % len(self.twiddle_chars)
            twiddle = self.twiddle_chars[twiddle_index]
            keys['tick'] = self.bs + twiddle
            self.bs = '\b' * len(twiddle)
        super(Twiddle_ticker_t, self).make_tick(*args, **keys)

