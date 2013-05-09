#!/usr/bin/env python

import re, time, string, dp_io, types

month_abbrevs = '(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'

LOCAL = 'local'
GMT = 'gmt'

MONDAY = 0
TUESDAY = 1
WEDNESDAY = 2
THURSDAY = 3
FRIDAY = 4
SATURDAY = 5
SUNDAY = 6

days = ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
        'Sunday')

############################################################                
def daynum_to_name(daynum):
    return days[daynum]

############################################################                
def this_year(tim=None):
    """this_year()
    return the current 4 digit year"""
    if tim == None:
        tim = time.time()
    return time.strftime('%Y', time.localtime(tim))

############################################################                
def this_month(tim=None):
    """this_month()
    return the current month number"""
    if tim == None:
        tim = time.time()
    return time.strftime('%m', time.localtime(tim))

#########################################################                
def this_day(tim=None):
    """this_day()
    return the current day of month number"""
    if tim == None:
        tim = time.time()
    return time.strftime('%d', time.localtime(tim))

############################################################                
def mk_today(instr, tim=None):
    if tim == None:
        tim = time.time()
    return '%s-%s-%s' % (this_month(tim), this_day(tim), this_year(tim))

############################################################                
def add_this_year(instr, tim=None):
    return instr + '-' + this_year(tim)

############################################################                
def mk_this_month(instr, tim=None):
    return '1-' + instr + '-' + this_year(tim)

############################################################                
def R(rex):
    # print 'rex>%s<\n' % rex
    return re.compile(rex, re.I)

def fmt_def_expand(re_str, fmt, separators, func):
    """Given an re_str which describes a legal date input format,
    a fmt which when fed to strptime will parse a time string that
    matches re_str, a list of separators and a fill_in function,
    generate a list of tuples with each '||' in re_str and fmt
    replaced by each element of separators."""
    ret = []

    for sep in separators:
        t_fmt = string.replace(fmt, '||', sep)
        #
        # special re chars. need to be escaped in re but not in fmt
        #
        if sep and sep in '.':
            sep = '\\' + sep
        t_re = string.replace(re_str, '||', sep)
        dp_io.debug('t_re>%s<, t_fmt>%s<',t_re, t_fmt)
        ret.append((R(t_re), t_fmt, func))

    return tuple(ret)

    
############################################################                
#
# Tuple components:
# [0] compiled regexp which recognizes the format
# [1] the format.  || is used to indicate where a separator
#      (see [2]) is allowed.  Any combination of separators may be used. 
# [2] a list of legitimate separators.
# [3] a function which is used to fill in unspecified information.  This
#      function is passed the original date string and a time_t from which
#      to get fill in info.  If this is None, then use time.time() to get
#      fill in info.  The function returns a new string which includes the
#      filled in info.  tuple[1] is then used to parse this new string.
#
############################################################                

# make a list of acceptible date separators
separators = map(None, '!/-_:,.')
time_formats = (
    fmt_def_expand('^\d+||\d+||\d\d\d\d$',
                   '%m||%d||%Y',
                   separators,
                   None) +
    fmt_def_expand('^\d+||\d+||\d\d$',
                   '%m||%d||%y',
                   separators,
                   None) +
    fmt_def_expand('^\d+||\d+$',
                   '%m||%d-%Y',
                   separators,
                   add_this_year) +
    fmt_def_expand('^\d+||'+month_abbrevs+'||\d\d\d\d$',
                   '%d||%b||%Y',
                   separators + [''],
                   None) +
    fmt_def_expand('^\d+||'+month_abbrevs+'||\d\d$',
                   '%d||%b||%y',
                   separators + [''],
                   None) +
    fmt_def_expand('^\d+||'+month_abbrevs+'$',
                   '%d||%b-%Y',
                   separators + [''],
                   add_this_year) +
    fmt_def_expand('^'+month_abbrevs+'||\d+$',
                   '%b||%d-%Y',
                   separators + [''],
                   add_this_year) +
    
    # one number or word... is the month
    ((R('^('+month_abbrevs+')$'), '%d-%b-%Y', mk_this_month),
     (R('^\d+$'),                 '%m-%d-%Y', mk_this_month),
    
    # some simple chars to mean today
     (R('^$|^(([-/.=])|t|to|tod|toda|today)$'), '%m-%d-%Y', mk_today))
    )

############################################################                
def find_time_fmt(t):
    for rex, fmt, default_func in time_formats:
        if rex.search(t):
            return fmt, default_func
    return None

############################################################                
def parse_date(time_str, time_for_fill_in=None, tz_adjust=LOCAL):
    """convert a variety of time/date strings into secs since epoch"""
    ret = find_time_fmt(time_str)
    if ret:
        fmt, fill_in_func = ret
        dp_io.debug('fmt>%s<, fillin_func>%s<\n', fmt, fill_in_func)
        if fill_in_func:
            time_str = fill_in_func(time_str, time_for_fill_in)
        dp_io.debug('time_str>%s<, fmt>%s<\n', time_str, fmt)
        try:
            t = time.mktime(time.strptime(time_str, fmt))
        except ValueError, e:
            dp_io.eprintf('mktime(%s, %s) failed.\n', time_str, fmt)
            return None
            
        if tz_adjust == LOCAL:
            t = t - time.timezone
        return t
    
    # could not recognize format
    return None

def parse_time(time_str, time_for_fill_in=None, tz_adjust=LOCAL):
    import sys
    f = open('/tmp/parse_time_callers', 'w+')
    f.write(sys.argv[0] + '\n')
    f.close()
    return parse_date(time_str, time_for_fill_in=None, tz_adjust=LOCAL)

############################################################                
#
# Tuple components:
# [0] tuple of legal abbreviations
# [1] the day number as per the python time module
#
############################################################                
day_names = (
    (('m', 'mo', 'mon', 'monday'), 0),
    (('tu', 'tue', 'tuesday'), 1),
    (('w', 'we', 'wed', 'wednesday'), 2),
    (('th', 'thu', 'thur', 'thurs', 'r', 'thursday'), 3),
    (('f', 'fr', 'fri', 'friday'), 4),
    (('sa', 'sat', 'saturday'), 5),
    (('su', 'sun', 'sunday'), 6))

############################################################                
def name_to_daynum(name):
    tname = string.lower(name)
    for name_list, daynum in day_names:
        for n in name_list:
            if tname == n:
                return daynum
    return None

############################################################                
def is_leapyear(year):
    return ((year % 4 == 0) and
            ((year % 100 != 0) or (year % 400 == 0)))

############################################################                
def daynum(time_t, tz_adjust=GMT):
    if tz_adjust == GMT:
        t = time.gmtime(time_t)
    else:
        t = time.localtime(time_t)
    return t[6]

############################################################                
def month_num_to_name(num):
    if num > 12 or num < 1:
        raise ValueError
    return month_abbrevs[num]

############################################################                
def std_timestamp(time_tuple=None, replace_colons_p=True,
                  replace_colons_with=".", date_time_separator="T"):
    # Are they serious? You can't pass None in order to get the default
    # behavior for time tuple?
    format_string = "%F" + date_time_separator + "%T"
    if time_tuple:
        stamp = time.strftime(format_string, time_tuple)
    else:
        stamp = time.strftime(format_string)
    if replace_colons_p:
        stamp = stamp.replace(":", replace_colons_with)
    return stamp

############################################################                
if __name__ == '__main__':
    import sys, getopt
    
    dp_io.debug_off()
    opts, args = getopt.getopt(sys.argv[1:], 'd')
    for o, v in opts:
        if o == '-d':
            dp_io.debug_on()

    if not args:
        args = ['']
        print 'test read from stdin'
        args = [sys.stdin]
    for f in args:
        if type(f) == types.StringType:
            f = open(f)
        while 1:
            t = f.readline()
            if not t:
                if type(f) == types.StringType:
                    f.close()
                break
            if t == '\n':
                continue
            t = t[0:-1]
            print 'input line>%s<' % t
            otim = t
            ret = find_time_fmt(t)
            if ret:
                fmt, func = ret
                tim = parse_date(t, tz_adjust=GMT)
                print 't>%s<, tim>%s< -->%s<' % (otim, tim, time.ctime(tim))
            else:
                print 'unrecognized format>%s<' % otim
            
            print '--'
