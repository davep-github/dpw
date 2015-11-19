#!/usr/bin/env python

import sys, types, re, time
import dp_utils, dp_time
from dp_io import fprintf
def Ticker_printf(ticker, fmt, *args, **kwargs):
    ticker_ostream = kwargs.get("ticker_ostream")
    if not ticker_ostream:
        ticker_ostream = ticker.ostream
    #print "ticker_ostream: {}".format(ticker_ostream)
    llen = 0
    if kwargs.get("just_flush_p"):
        #print "just flushing..."
        # Seems to do nothing.
        ticker_ostream.flush()
        #print "...just flushed."
    else:
        llen = fprintf(ticker_ostream, fmt, *args)
        if kwargs.get("flush_p"):
            ticker_ostream.flush()
    return llen


time_time = time.time

class Ticker_t(object):
    def __init__(self, tick_interval, increment=1, init_string="counting: ",
                 comma=", ", init_count=0, ostream=sys.stdout, forward=False,
                 unit_name="line",
                 printor=Ticker_printf,
                 tick_show_units_p=False,
                 max_output_units_before_newline=False,
                 max_output_line_len_before_newline=False,
                 max_output_units_before_exit=False,
                 timestamp_p=False,
                 elapsed_timestamp_p=False,
                 timestamp_separator_string=": ",
                 grand_total_p=True):
        self.tick_interval = tick_interval
        self.increment = increment
        self.init_string = init_string
        self.unit_name = unit_name
        self.comma = comma
        self.init_count = init_count
        self.printor = printor
        self.ostream = ostream
        self.grand_total_p = grand_total_p
        self.tick_show_units_p = tick_show_units_p
        self.max_output_units_before_newline = max_output_units_before_newline
        self.max_output_line_len_before_newline = max_output_line_len_before_newline
        self.max_output_units_before_exit = max_output_units_before_exit
        self.count_at_last_newline = 0
        self.timestamp_p = timestamp_p
        self.elapsed_timestamp_p = elapsed_timestamp_p
        self.timestamp_separator_string = timestamp_separator_string
        self.time0 = int(time_time())
        self.any_timestamp_p = timestamp_p or elapsed_timestamp_p
        self.output_line_len = 0
        # Keep last as it will use variables that need to have already been
        # defined.
        self.reset_counter()

    def twiddling_p(self):
        return False

    def do_printor(self, *args, **kwargs):
        llen = self.printor(*args, **kwargs)
        # print >>sys.stderr, "do_printor: llen: %d" % (llen,)
        self.output_line_len += llen
        # print >>sys.stderr, "do_printor: self.output_line_len: %d" % (self.output_line_len,)

    def reset_counter(self):
        self.counter = self.init_count
        if self.init_string:
            self.do_printor(self, "%s", self.init_string)
            # print >>sys.stderr, "reset_counter: self.output_line_len: %d" % (self.output_line_len, )
        self.sep_string = ""
        self.num_ticks = 0

    def flush(self):
        #print "enter ticker.flush()"
        self.do_printor(self, None, just_flush_p=True)
        # print >>sys.stderr, "flush: self.output_line_len: %d" % (self.output_line_len,)
 #       cause_a_traceback += 1
        #print "exit: ticker.flush()"

    def make_timestamp(self):
        ts_string = ""
        ts_ts_sep = ""
        if self.timestamp_p:
            ts_string = dp_time.std_timestamp()
            ts_ts_sep = ": "
        if self.elapsed_timestamp_p:
            ts_string = "%s%s%8.2f" % (ts_string, ts_ts_sep,
                                       time_time() - self.time0,)
        return ts_string + self.timestamp_separator_string
    
    def make_tick(self, tick=None, call_tick=None, tick_prefix=""):
        if not tick:
            tick=call_tick
        #print "self.sep_string>%s<, tick>%s<\n" % (self.sep_string, tick)
        if self.tick_show_units_p:
            tick = dp_utils.numPlusUnits(float(self.counter),
                                         allow_fractions_p=True,
                                         powers_of_two_p=False)
        ts_string = ""
        if self.any_timestamp_p:
            ts_string = self.make_timestamp()
        # Line breaks (newlines) happen here.
        output_str = "%s%s%s%s" % (self.sep_string, tick_prefix,
                                   ts_string, tick)
        self.do_printor(self, "%s", output_str)
        self.sep_string = self.comma

    def fini(self, force_grand_total_p=False, reason=""):
        self.flush()
        if force_grand_total_p or self.grand_total_p:
            print "\n%sTotal: %s %s" % (reason,
                                        self.counter,
                                        dp_utils.pluralize(self.unit_name,
                                                           self.counter))

    def tick_not_ready(self):
        pass

    def tick_ready(self, tick, tick_prefix, forced_p=False):
        self.make_tick(tick=tick, call_tick=self.counter,
                       tick_prefix=tick_prefix)
        if not forced_p:
            self.num_ticks += 1

    def __call__(self, reset_counter=False, set_n=False,
                 increment=None, tick=None, tick_prefix="",
                 force_tick_p=False, ostream=None):
        if force_tick_p:
            self.tick_ready(tick=tick, tick_prefix=tick_prefix,
                            forced_p=force_tick_p)
            return
        if reset_counter is not False:
            self.reset_counter()
        if set_n is not False:
            self.tick_interval = set_n
        if self.tick_interval is not None:
            if (self.counter % self.tick_interval) == 0:
                self.tick_ready(tick=tick, tick_prefix=tick_prefix)
            else:
                self.tick_not_ready()
            self.counter += increment or self.increment
        if ((self.max_output_units_before_exit is not False)
            and (self.counter >= self.max_output_units_before_exit)):
            self.fini(reason="%s limit reached[%d], exiting\n" % (
                self.unit_name,
                int(self.max_output_units_before_exit)))
            # Indicate successful failure.
            sys.exit(2)
        if self.max_output_units_before_newline is not False:
            count_since_last_newline = (self.num_ticks
                                        - self.count_at_last_newline)
#            print "num_ticks: %s, count: %s, max_output_units_before_newline: %s\n" % (
#                self.num_ticks, self.count, self.max_output_units_before_newline)
            if count_since_last_newline >= self.max_output_units_before_newline:
                self.sep_string = "\n"
                self.count_at_last_newline = self.num_ticks
        if ((self.max_output_line_len_before_newline is not False)
            and (self.output_line_len
                 >= self.max_output_line_len_before_newline)):
            # print >>sys.stderr, "__call__(): self.output_line_len: %d" % (self.output_line_len)
            self.sep_string = "\n"
            # The newline gets charged to the next line, so compensate for
            # that.
            self.output_line_len = -len(self.sep_string)

class Char_ticker_t(Ticker_t):
    def __init__(self, tick_interval, tick_char='.', increment=1,
                 init_string="", comma="", init_count=0, ostream=sys.stdout,
                 unit_name="line",
                 max_output_units_before_newline=False,
                 max_output_line_len_before_newline=False,
                 max_output_units_before_exit=False,
                 tick_show_units_p=False,
                 printor=Ticker_printf):
        super(Char_ticker_t, self).__init__(
            tick_interval=tick_interval,
            increment=increment,
            init_string=init_string,
            comma=comma,
            max_output_units_before_newline=max_output_units_before_newline,
            max_output_line_len_before_newline=max_output_line_len_before_newline,
            max_output_units_before_exit=max_output_units_before_exit,
            init_count=init_count,
            ostream=ostream,
            unit_name=unit_name,
            tick_show_units_p=tick_show_units_p,
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
                 max_output_units_before_newline=False,
                 max_output_units_before_exit=False,
                 comma="", init_count=0, printor=Ticker_printf):
        super(Twiddle_ticker_t, self).__init__(tick_interval=tick_interval,
                                               increment=increment,
                                               init_string=init_string,
                                               comma=comma,
                                               ostream=ostream,
                                               init_count=init_count,
                                               max_output_units_before_exit=False,
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

