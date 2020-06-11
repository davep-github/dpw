#!/usr/bin/env python

"""date_sequence.py
Generate a sequence of dates between a start and and end date (inclusive).
Allow for only specified days of the week to be generated.
Allow user to provide text annotations for generated dates."""

import os, sys, string, time, dp_time, types, copy, dp_io, getopt

deb = dp_io.debug
dp_io.debug_on()
dp_io.debug_off()

days_per_month = (31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)


############################################################                
class SimpleDate:
    
    ############################################################
    def __init__(self, time_t=None):
        if time_t == None:
            time_t = time.time()
        time_tuple = time.localtime(time_t)
        self.month = int(time_tuple[1])
        self.day = int(time_tuple[2])
        self.year = int(time_tuple[0])
        self.dow = int(time_tuple[6])

    ############################################################
    def inc(self):
        self.dow = (self.dow + 1) % 7
        self.day = self.day + 1
        if self.month == 2:
            if dp_time.is_leapyear(self.year):
                lim = 29
            else:
                lim = 28
        else:
            lim = days_per_month[self.month-1]
        if self.day > lim:
            self.day = 1
            self.month = self.month + 1
            if self.month > 12:
                self.month = 1
                self.year = self.year + 1

    ############################################################
    def add(self, num=1):
        while num > 0:
            self.inc()
            num = num - 1

    ############################################################
    def cmp(self, other):
        diff = self.year - other.year
        if diff:
            return diff
        diff = self.month - other.month
        if diff:
            return diff
        return self.day - other.day

    ############################################################
    def eq(self, other):
        return self.cmp(other) == 0

    ############################################################
    def mdY(self):
        return '%02d/%02d/%d' % (self.month, self.day, self.year)
    
    ############################################################
    def __str__(self):
        return self.mdY()
        
############################################################                
class DateRange:

    ############################################################
    def __init__(self, start_date=None, end_date=None):
        self.done = 0
        now = time.time()
        if not start_date:
            self.start_date = now
        else:
            self.start_date = dp_time.parse_date(start_date, now, dp_time.GMT)
            if not self.start_date:
                raise 'Unrecognized start date >%s<' % start_date

        if not end_date:
            self.end_date = now
        else:
            self.end_date = dp_time.parse_date(end_date, now,  dp_time.GMT)
            if not self.end_date:
                raise 'Unrecognized end date >%s<' % end_date

        self.start_date = SimpleDate(self.start_date)
        self.cur_date = copy.copy(self.start_date)
        self.end_date = SimpleDate(self.end_date)


    ############################################################
    def set_days(self, *pargs):
        self.days = []
        for day in pargs:
            if type(day) == int:
                daynum = day
            elif type(day) == bytes:
                daynum = dp_time.name_to_daynum(day)
                if daynum == None:
                    raise 'Unknown day name >%s<' % day
            else:
                raise 'Unsupported type for day name >%s<' % type(day)

            deb('daynum: %s, type: %s\n', daynum, type(daynum))
            self.days.append(daynum)
            
    ############################################################
    def __next__(self):
        while 1:
            if self.done:
                return None

            deb('next, cur: %s\n', self.cur_date)
            if self.cur_date.eq(self.end_date):
                self.done = 1

            deb('days: %s| %d\n', self.days, self.cur_date.dow)
            if not self.days or self.cur_date.dow in self.days:
                ret = copy.copy(self.cur_date)
                self.cur_date.inc()
                return ret

            self.cur_date.inc()

    ############################################################
    def get_seq_mdY(self):
        retl = []
        while 1:
            ret = next(self)
            if not ret:
                break
            retl.append('%s' % ret)
            
        return retl

    ############################################################
    def reset(self):
        self.cur_date = copy.copy(self.start_date)
        self.done = 0


############################################################
def gen_seq(start, end, days, texts=[], sep=' '):
    """Generate a sequence of dates and texts"""
    
    dr = DateRange(start, end)
    dr.set_days(*days)

    deb('start: %s\n', dr.start_date)
    deb('end  : %s\n', dr.end_date)

    texti = 0
    textm = len(texts)
    if textm == 0:
        text = ''

    outl = []
    while 1:
        dat = next(dr)
        if not dat:
            break
        if textm:
            text = texts[texti]
            texti = (texti + 1) % textm
        outl.append(dat.mdY() + sep + text)

    return outl
    

############################################################                
if __name__ == "__main__":
    
    progname = os.path.basename(sys.argv[0])
    texts = []
    
    if len(sys.argv) == 1:
        print("""usage: %s [-t txt...] start-date end-date [day...]
        
Generate a sequence of dates from start-date to end-date.
day... specifies which days of the week to produce.
-t txt says to add txt to each date produced.  Txts will be cycled through
round-robin and attached to each date produced.""" % progname)
        sys.exit(0)
        
    opts, args = getopt.getopt(sys.argv[1:], 't:')
    for o, v in opts:
        if o == '-t':
            texts.append('\t' + v)

    seq = gen_seq(args[0], args[1], args[2:], texts)
    
    if seq:
        print(string.join(seq, '\n'))
