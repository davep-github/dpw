#!/usr/bin/env python
#-*-Python-*-
# $Id: xmsg.py,v 1.1.1.1 2001/01/17 22:22:31 davep Exp $

import sys
import getopt
import string
from Tkinter import *
 
class Application(Frame):
	def __init__(self, master=None):
		Frame.__init__(self, master)
		self.master.title("Strunza!")
		self.parse_args()
		self.create_widgets()
		self.pack()
		for key in 'qQxX':
		    self.bind_all('<KeyPress-%c>' % key,
				  self.quit_event)
		for key in '1oOYyTt':
		    self.bind_all('<KeyPress-%c>' % key,
				  self.ok_event)

	def quit_event(self, event):
            print "quit"
	    self.quit()

	def ok_event(self, event):
            print "ok"
	    self.quit()

	def usage(self):
	    sys.stderr.write('usage: [-t title] message...')
	    sys.exit(1)

	def parse_args(self):
		options, self.args = getopt.getopt(sys.argv[1:], 't:')
		for opt, val in options:
			#print 'opt', opt, 'val', val
			if (opt == '-t'):
			    self.master.title(val)
			else:
			    self.usage()

	def create_widgets(self):
	    self.message = Message(self, 
				   text=string.joinfields(self.args, ' '))
	    self.message.pack(side=TOP, expand=TRUE, fill=BOTH)
	    self.pack(side=TOP, expand=TRUE, fill=BOTH)

#
###################################
#
app = Application()
app.mainloop()
