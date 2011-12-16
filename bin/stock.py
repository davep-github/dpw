#!/usr/bin/env python
#
# $Id: stock.py,v 1.1.1.1 2001/01/17 22:22:30 davep Exp $
#

import urllib
import string
import socket
import sys
import os
import getopt
from Tkinter import *

# fetch -o - 'http://finance.yahoo.com/d?f=nl1d1t1c1p2va2bapoj1mwerr1dyx&s=ge' 2>/dev/null

#
# FE: add short format: price and change. switch with key 's', 'l'
#
inc = 0.0
inc_test = 0
#
# snarfed from httplib.py for now...
#

def get_quote(url):

    #print url
    u = urllib.urlopen(url)
    
    quote = u.read()
    u.close
    quote = string.rstrip(quote)
    #print quote
    
    ql = string.split(quote, ',')
    
    #i = 0
    #for qe in ql:
    #    print "%2d: qe>%s<" % (i, qe)
    #    i = i + 1

    ql[4] = string.atof(ql[4])

    # XXX testing
    if inc_test:
        global inc
        #print ql[1], ql[4]
        ql[1] = string.atof(ql[1])
        ql[1] += inc
        ql[4] += inc
        #print ql[1], ql[4]
        inc += 0.1
    # XXX
    
    change = ql[4]
    #print change, type(change)
    if change < 0.0:
        color = 'red'
    else:
        color = 'green4'

    return ({'name': ql[0],
             'color': color,
             'price': ql[1],
             'change': ql[4],
             'change_pct': ql[5],
             'high': ql[10],
             'low': ql[11]})

def get_quotes(
    symlist=[],
    url_fmt='http://finance.yahoo.com/d?f=nl1d1t1c1p2va2bapoj1mwerr1dyx&s=%s',
    dl = 0):

    quotes = []
    for sym in symlist:
        sym = string.upper(sym)
        url = url_fmt % sym
        q = get_quote(url)
        q['sym'] = sym
        #print q
        quotes.append(q)

    return quotes                       # list of dictionaries

def fmt_quote_long(quote):
    return '%(sym)s: %(price)s, ch: %(change)s(%(change_pct)s), hi: %(high)s, lo: %(low)s' % quote

def fmt_quote_short(quote):
    return '%(sym)s: %(price)s/%(change)s' % quote

def fmt_quote_micro(quote):
    return '%(sym)s: %(price)s' % quote

class Ticker(Frame):
    def __init__(self, master=None, word_list=[], tick_interval=1000, update_interval=10, update_func=None):
        Frame.__init__(self, master)
        self.word_list = word_list
        self.tick_interval = tick_interval
        self.update_interval = update_interval
        self.update_func = update_func
        self.texts = []
        self.needs_update = 0
        
        #self.parse_args()
        self.create_widgets()
        self.master.title("bare:::")
        self.pack(expand=0, fill=X)
        self.after(self.tick_interval, self.do_tick)
        self.num_ticks = 0

    def settext(self, text):
        self.text = text
        self.label.configure(text=text)
        
    def do_tick(self):
        if (self.num_ticks % self.update_interval) == 0 and self.update_func:
            self.needs_update = 1
        if self.num_ticks % self.final_x == 0:
            if self.needs_update:
                #print 'update'
                self.word_list = self.update_func()
                self.build_text()
                self.needs_update = 0
            self.canvas.xview_moveto(0)
        else:
            self.canvas.xview_scroll(1, UNITS)
        self.num_ticks += 1
            
        self.after(self.tick_interval, self.do_tick)

    #
    # FE: remember each stock's start position and position to that
    # when a number key (1-9) is pressed.
    # FE: put update time in title (if we keep the title.
    # FE: update on 'r' key
    
    def build_text(self):
        x = 0
        for t in self.texts:
            self.canvas.delete(t)
        for i in range(10):
            for word in self.word_list:
                color = word[0]
                s = word[1]
                self.texts.append(self.canvas.create_text(x, 2, anchor=NW,
                                                          fill=color,
                                                          text=s))
                bbox = self.canvas.bbox(self.texts[-1])
                x = bbox[2] + 30
                #print "x: ", x
                if i == 0:
                    self.final_x = x

    def do_quit(self, event=None):
        self.quit()
        
    def create_widgets(self):
        #scrollregion="-1000m 0m 1000m 10m",
        self.focus()
	for k in ("q", "Q", "Meta-q", "Meta-Q", "x", "X", "Meta-x",
		  "Meta-X"):
	    self.bind('<%s>' % k, self.do_quit)
        
        self.canvas = Canvas(self, 
                             relief=SUNKEN, xscrollincrement=1,
                             width='60m', height='6m')
        self.build_text()
        self.canvas.pack(expand=1, fill=X)
        
opts, args = getopt.getopt(sys.argv[1:], 'dsm')
dl = 0
fmt_quote = fmt_quote_long
for o, a in opts:
    if o == '-d': dl = dl + 1
    if o == '-s': fmt_quote = fmt_quote_short
    if o == '-m': fmt_quote = fmt_quote_micro
        
def cat_quotes(args):
    quotes = get_quotes(args, dl=dl)
    s = []
    for q in quotes:
        #print q
        sym = q['sym']
        color = q['color']
        s.append((color, fmt_quote(q)))
    return s

os.nice(20)
s = cat_quotes(args)
#print s

t = Ticker(word_list=s, tick_interval=50,
           update_func=lambda args=args: cat_quotes(args))

t.mainloop()
