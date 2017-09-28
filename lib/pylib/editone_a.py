#!/usr/bin/env python
import dp_io
from Tkinter import *

class EditOne(Toplevel):
    def __init__(self, master, default='', prompt='', title=None, modal=None, borderwidth=12):
	Toplevel.__init__(self)
	if title:
	    self.title(title)
	self.default = default
        self.modal = modal
        self.borderwidth = borderwidth
        frame = Frame(self, borderwidth=self.borderwidth)
	label = Label(frame, text=prompt)
	label.pack(side=LEFT)
	edit = self.edit = Entry(frame, borderwidth=3)
	edit.insert('@0', self.default)
	edit.bind('<Return>', self.enter)
	edit.bind('<Escape>', self.escape)
	for key in 'oOqQXx':
	    edit.bind('<Alt-%c>' % key, self.all_event)
	edit.pack(side=LEFT, fill=X, expand=TRUE)
        
	self.ok = Button(frame, text='Ok', 
                         command=lambda o=self: \
                         EditOne.edit_button(o, 'ok'))
        
	self.cancel = Button(frame, text='Cancel',
                             command=lambda o=self: \
                             EditOne.edit_button(o, 'cancel'))
        
	self.ok.pack(side=LEFT, fill=X)
	self.cancel.pack(side=LEFT, fill=X)
        frame.pack(side=LEFT, fill=X, expand=TRUE)
        if master:
            self.transient(master)
        #
        # Actualize geometry information
        # this lets the grab work
        #
        self.update_idletasks() 

    def all_event(self, event):
 	if event.char in 'qQ':
 	    self.cancel.invoke()
 	else:
 	    self.ok.invoke()

    def enter(self, event):
	self.ok.invoke()

    def escape(self, event):
        self.cancel.invoke()

    def go(self, modal=None):
	self.edit.focus_set()
        if modal or self.modal:
            self.grab_set()
	self.wait_window()
	return self.default

    def edit_button(self, str):
	if str == 'ok':
	    self.default = self.edit.get()
        else:
            self.default = None
	self.destroy()

if __name__ == "__main__":
    e = EditOne(None, 'defffff', 'Well', 'Edit Well')
    s = e.go()
    print 's:', s
