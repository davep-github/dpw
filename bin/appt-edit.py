#!/usr/bin/env python

from Tkinter import *
from tk_extra import *
import os, string, re, sys, getopt, stat, editone_a, dp_time, dp_io, time
import date_sequence

dp_io.debug_off()
deb=dp_io.debug

"""TODO
when deleting the 0th used date, revalidate the new first used date.
validate end >= start
"""

#################################################################
class Application(Frame):
    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.now = time.time()
        self.apt_text_default = ''
        self.starting_daynum_valid = 0
        self.starting_daynum = -1       # none, yet
        self.first_used_daynum = -1     # none, yet
        self.parse_args()
        self.create_widgets()
        self.master.title("Appt Edit")
        self.pack(expand=TRUE, fill=BOTH)
        self.reset()

    #################################################################
    def usage(self):
        sys.stderr.write('usage: ')
        sys.exit(1)

    #################################################################
    def parse_args(self):
        options, args = getopt.getopt(sys.argv[1:], '')
        for opt, val in options:
            deb('opt>%s<, val>%s<\n', opt, val)
            if (opt == '-f'):
                blah
            else:
                self.usage()

    #################################################################
    def create_widgets(self):
	self.create_title()
	self.create_date_entries()
	self.create_day_entries()
        self.create_buttons()
        self.create_status_bar()

    def emit(self, ofile=sys.stdout):
        if not self.starting_daynum_valid:
            self.show_status('Starting daynum is not valid')
            return

        if self.check_dates():
            return

        self.clear_status()

        #
        # call the date sequence stuff
        # gen_seq(start, end, days, texts=[])
        # split the lines from used_days into day and text
        #
        nitems = self.used_days.index(END)
        days = []
        texts = []
        for i in range(nitems):
            day, text = self.used_day_extract(self.used_days.get(i))
            if not day:
                continue
            days.append(day)
            texts.append(text)
        l = date_sequence.gen_seq(self.start_date.get(),
                                  self.end_date.get(),
                                  days,
                                  texts)

        ofile.write(string.join(l, '\n') + '\n')
        
    #################################################################
    def emit_and_exit(self):
        deb('emit and exit\n')
        self.emit()
        sys.exit(0)

    #################################################################
    def test(self):
        deb('test\n')
        self.emit(ofile=sys.stderr)

    #################################################################
    def just_exit(self):
        deb('just exit\n')
        sys.exit(0)

    #################################################################
    def show_status(self, txt, fg='RED'):
        self.status_bar.configure(text=txt, fg=fg)
	self.status_bar.pack(fill=X)
        self.update()

    #################################################################
    def clear_status(self):
        self.show_status('')

    #################################################################
    def reset_dates(self):
        self.start_date.delete(0,END)
        self.start_time_t = None
        self.start_dow.configure(text='<unset>')
        self.end_date.delete(0,END)
        self.end_time_t = None
        self.end_dow.configure(text='<unset>')

    #################################################################
    def reset(self):
        self.apt_text_default = ''
        self.starting_daynum_valid = 0
        self.starting_daynum = -1       # none, yet
        self.first_used_daynum = -1     # none, yet
        self.clear_status()
        self.reset_dates()
        self.fill_entry_with_days(self.avail_days)
        self.used_days.delete(0, END)
        self.start_date.focus()
        
    #################################################################
    def create_status_bar(self):
        frame = Frame(self, borderwidth=12)
        title = Label(frame, text='Status:')
        title.pack(side=TOP, anchor=W)
        self.status_bar = Label(frame, relief=SUNKEN, borderwidth=2)
        self.status_bar.pack(side=LEFT, fill=X, expand=TRUE)
        frame.pack(side=BOTTOM, fill=X, expand=TRUE)
        
    #################################################################
    def create_buttons(self):
        frame = Frame(self, borderwidth=12)
        ok = Button(frame, text='Done', command=self.emit_and_exit)
        ok.pack(side=LEFT, expand=TRUE)
        test = Button(frame, text='Test', command=self.test)
        test.pack(side=LEFT, expand=TRUE)
        reset = Button(frame, text='Reset', command=self.reset)
        reset.pack(side=LEFT, expand=TRUE)
        cancel = Button(frame, text="Quit", command=self.just_exit)
        cancel.pack(side=RIGHT, expand=TRUE)
        frame.pack(side=TOP, fill=X, expand=TRUE)

    #################################################################
    def create_title(self):
	self.title = Label(self, relief=RAISED, borderwidth=2,
			   text='Appointment Editor for PCal')
	self.title.pack(fill=X)
        self.update()

    #################################################################
    def validate_new_used_day(self, day, set_status=1, adding=0):
        """Make sure the new used daynum matches the daynum of the
        starting date"""

        deb('in vnud\n')
        
        if adding and self.used_days.index(END) != 0:
            # the new day will not be the first
            deb('vnud(): not 0th item\n')
            return 1
        
        if self.starting_daynum == -1:
            # no starting daynum, nothing to validate against
            deb('vnud(): no starting daynum\n')
            return 1

        daynum = dp_time.name_to_daynum(day)

        deb('vnud(): type(daynum): %s, type(starting_daynum): %s\n',
            type(daynum), type(self.starting_daynum))

        deb('vnud(): daynum: %d, starting_daynum: %d\n',
            daynum, self.starting_daynum)
        
        if daynum != self.starting_daynum:
            if set_status:
                self.show_status('First used day must be the same as the starting day (%s)' % dp_time.daynum_to_name(self.starting_daynum))                
            self.starting_daynum_valid = 0
        else:
            if set_status:
                self.clear_status()
            self.starting_daynum_valid = 1

        deb('vnud(): valid: %d\n',  self.starting_daynum_valid)
        return self.starting_daynum_valid

    #################################################################
    def validate_starting_daynum(self, daynum, set_status=1):
        """Make sure the new starting daynum matches the daynum of the
        first used date"""

        if daynum == None:
            self.starting_daynum_valid = 0
            return self.starting_daynum_valid
    
        deb('in vsd\n')
        
        if self.used_days.index(END) == 0:
            # there are no used days
            deb('vsd(): no used days\n')
            return 1

        deb('vsd(): daynum: %d, first_used_daynum: %d\n',
            daynum, self.first_used_daynum)
        
        if daynum != self.first_used_daynum:
            if set_status:
                self.show_status('Starting must be the same as the first used day (%s)' % dp_time.daynum_to_name(self.first_used_daynum))
            self.starting_daynum_valid = 0
        else:
            if set_status:
                self.clear_status()
            self.starting_daynum_valid = 1

        deb('vsd(): valid: %d\n',  self.starting_daynum_valid)
        return self.starting_daynum_valid

    #################################################################
    def save_first_used_daynum(self, day):
        self.first_used_daynum = dp_time.name_to_daynum(day)

    #################################################################
    def check_dates(self, start=None, end=None, set_status=1):
        if start == None:
            start = self.start_time_t
        if end == None:
            end = self.end_time_t

        deb('start: %f, end: %f\n', start, end)
        if start != None and end != None:
            if start > end:
                if set_status:
                    self.show_status('End date is before Start date')
                    return -1
        return 0

    #################################################################
    def process_date(self, entry):
        is_start = entry is self.start_date
        str = string.strip(entry.get())
        if str == '':
            str = time.strftime('%d-%b-%Y', time.gmtime(self.now))

        time_t = dp_time.parse_date(str, tz_adjust=dp_time.GMT)
            
        if time_t == None:
            self.show_status('Invalid date format')
            daynum = None
            dow = '<unset>'
        else:
            self.clear_status()
            daynum = dp_time.daynum(time_t)
            dow = dp_time.daynum_to_name(daynum)
            # normalize date display
            str = time.strftime('%d-%b-%Y', time.gmtime(time_t))
            entry.delete(0,END)
            entry.insert(0, str)
            
        if is_start:
            if self.validate_starting_daynum(daynum):
                self.starting_daynum = daynum
                self.start_dow.configure(text=dow)
                self.start_time_t = time_t
                deb('starting daynum: %d\n', daynum)
                return
            else:
                # clear the date field
                deb('clear bad date\n')
                self.start_time_t = None
                entry.delete(0,END)
                self.start_dow.configure(text='<unset>')
        else:
            self.end_dow.configure(text=dow)
            self.end_time_t = time_t

        self.check_dates()

    #################################################################
    def create_date_entry(self, parent=None, label_text='Date'):
        frame = Frame(parent or self, borderwidth=2, relief=GROOVE)
        label = Label(frame, text=label_text)
        entry = Entry(frame)
	label.pack(side=TOP, anchor=W)
	entry.pack(side=TOP, fill=X, expand=TRUE)
        l = Label(frame, text='Day: ')
        l.pack(side=LEFT)
        dow = Label(frame, text='<unset>')
        dow.pack(side=LEFT)

        return entry, frame, dow

    #################################################################
    def create_date_entries(self):
        frame = Frame(self, borderwidth=12)
        dates = []
        dows = []
        for label in 'Start', 'End':
            t = label + ' ' + 'Date:'
            d, f, dow = self.create_date_entry(frame, t)
            f.pack(side=LEFT, fill=BOTH, expand=TRUE)
            func = lambda o=self, event=None, o2=self, entry=d: \
                       o2.process_date(entry)
            d.bind('<Return>', func)
            dates.append(d)
            dows.append(dow)
        self.start_date = dates[0]
        self.end_date = dates[1]
        self.start_dow = dows[0]
        self.end_dow = dows[1]

        frame.pack(side=TOP, fill=BOTH, expand=TRUE)

    #################################################################
    def add_used_day(self, day, text):
        deb('aud, day: %s\n', day)
        if not self.validate_new_used_day(day, adding=1):
            return

        if self.used_days.index(END) == 0:
            self.save_first_used_daynum(day)
            
        spaces = (len("wednesday") + 2 - len(day)) * ' '
        deb('add spaces: %d\b', len(day) + len(spaces))
        self.used_days.insert(END, day + spaces + text)

    #################################################################
    def add_avail_day(self, new_day):
        n = self.avail_days.index(END)
        day = dp_time.name_to_daynum(new_day)
        for i in range(n):
            this_day= dp_time.name_to_daynum(self.avail_days.get(i))
            if day < this_day:
                self.avail_days.insert(i, new_day)
                return
        self.avail_days.insert(END, new_day)

    #################################################################
    def avail_days_select(self, event):
        deb('avail_days_select, event>%s<\n', event)
        sel_idx = self.avail_days.curselection()
        deb('list>%s<\n', string.join(sel_idx, '\n'))
        for idx in sel_idx:
            day = self.avail_days.get(idx)
            if self.validate_new_used_day(day, adding=1):
                d = editone_a.EditOne(self,
                                      prompt='Enter %s\'s appt text' % day,
                                      modal=1, default=self.apt_text_default)
                t = d.go()
                deb('t>%s<\n', t)
                if t == None:
                    continue
                self.avail_days.delete(idx)
                self.add_used_day(day, t)
                self.apt_text_default = t

    #################################################################
    def used_day_extract(self, day):
        m = re.search('^(\S+)\s*(.*)$', day)
        if m:
            ret = (m.group(1), m.group(2))
        else:
            ret = (None, None)
            
        deb('uded(), day>%s<\n', ret[0])
        return ret
        
    #################################################################
    def used_days_select(self, event):
        deb('used_days_select, event>%s<\n', event)
        sel_idx = self.used_days.curselection()
        deb('list>%s<\n', string.join(sel_idx, '\n'))
        for idx in sel_idx:
            day = self.used_days.get(idx)
            self.used_days.delete(idx)
            day, dummy = self.used_day_extract(day)
            if day:
                self.add_avail_day(day)

        nitems = self.used_days.index(END)
        if nitems == 0:
            # all are gone.
            self.first_used_daynum = -1     # none any more
            return

        # make sure current first item is ok
        day = self.used_days.get(0)
        day, dummy = self.used_day_extract(day)
        self.validate_new_used_day(day, adding=0)

    #################################################################
    def fill_entry_with_days(self, entry):
        entry.delete(0, END)
        for day in ('Mon', 'Tues', 'Wednes', 'Thurs', 'Fri', 'Satur', 'Sun'):
            entry.insert(END, '%sday'%day)
        
    #################################################################
    def create_avail_entry(self, parent):
        frame = Frame(parent)
        label = Label(frame, text='Available Days:')
	label.pack(side=TOP, anchor=W)

        l, f = tkx_scrollbox(frame,
                             bindings={'Double-1':(self.avail_days_select, 1)},
                             sel_mode=SINGLE)
        f.pack(side=LEFT, fill=BOTH, expand=TRUE)
        frame.pack(side=LEFT, fill=NONE, expand=FALSE)
        self.avail_days = l

    #################################################################
    def create_used_entry(self, parent):
        frame = Frame(parent)
        label = Label(frame, text='Used Days:')
	label.pack(side=TOP, anchor=W)

        l, f = tkx_scrollbox(frame,
                             font='fixed',
                             bindings={'Double-1': (self.used_days_select, 1)})
        f.pack(side=LEFT, fill=BOTH, expand=TRUE)
        frame.pack(side=LEFT, fill=BOTH, expand=TRUE)
        self.used_days = l

    #################################################################
    def create_day_entries(self):
        frame = Frame(self, borderwidth=12)
        self.create_used_entry(frame)
        self.create_avail_entry(frame)
        frame.pack(side=TOP, fill=X, expand=TRUE)
        
#
#################################################################
#
app = Application()
app.mainloop()
