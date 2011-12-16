#!/usr/local/bin/python
#-*-Python-*-
# $Id: xplay.py,v 1.3 2001/07/29 05:44:41 davep Exp $

from Tkinter import *
import FileDialog
import os
import getopt
import sys
import string
import regex
import signal
import editone_a

play_cmds = [
    ('midi', 'playmidi -f %s'),
    ('dsp', 'xmms %s'),
    #('dsp', 'sox %s -t sbdsp /dev/dsp')
    ]

PLAYMIDI=play_cmds[0]
DEF_PLAYER=play_cmds[1]

DEF_SOUND_DIR='/stuff/sounds'

#
# map a file string to a player
#
play_map = [
    ('MIDI', PLAYMIDI),
    ('^Waveform', DEF_PLAYER),
    ('MP3', DEF_PLAYER),
    ('^AIFF', DEF_PLAYER),
    ('u-law', DEF_PLAYER),
    ('.', DEF_PLAYER)]			# default

class fake_event:
    def __init__(self, char=None):
	self.char = char

def sig_chld(*args):
    #print 'sigchld: it died', args, 'pid', app.pid
    app.sig_chld()

# def sig_usr1(*args):
#     app.pid = None
#     app.play_button_to_play()
#     print 'in sig_usr1'

class Application(Frame):
    def __init__(self, master=None):
	Frame.__init__(self, master)
	self.papa_pid = os.getpid()
	self.pid = None
	self.debug = None
	self.select_filter = '*'
	self.select_path = DEF_SOUND_DIR
	self.play_cmd = ''
	self.set_title()
	self.create_widgets()
	self.parse_args()
	for k in "xXqQDd":
	    self.bind_all("<Alt-%c>" % k,
			  self.quit_event)
	self.bind_all('<Alt-p>', self.play_event)
	self.bind_all('<Alt-i>', self.file_event)
	self.pack(expand=YES, fill=X)
	signal.signal(signal.SIGCHLD, sig_chld)
	#signal.signal(signal.SIGUSR1, sig_usr1)

    def sig_chld(self):
	if app.pid:
	    os.waitpid(app.pid, 0)		# calling all zombies
	    self.pid = None
	    self.play_button_to_play()
	    
    def ticker(self):
	self.update()
	if self.pid:
	    self.after(100, self.ticker)

    def set_title(self, typ=None):
	if typ == None:
	    self.master.title("xplay")
	else:
	    self.play_type = typ
	    self.master.title("xplay (%s)" % typ)
	
    def play_button_to_play(self):
	    self.play_b.config(text='Play', command=self.play)

    def play_button_to_stop(self):
	    self.play_b.config(text='Stop', command=self.stop_player)

    def stop_player(self):
	    #print 'pid:', self.pid
	    if self.pid:
		os.kill(self.pid, signal.SIGINT)
		self.pid = None
	    self.play_button_to_play()

    def quit_event(self, event):
	if event.char in 'qQ' and self.pid:
	    self.stop_player()
	self.quit()

    def my_quit(self):
	self.quit_event(fake_event('q'))

    def parse_args(self):
	options, args = getopt.getopt(sys.argv[1:], 'f:t:xhH?d')
	for opt, val in options:
	    #print 'opt', opt, 'val', val
	    if (opt == '-f'):
		self.select_path = os.path.dirname(val)
		self.set_file(val)
		self.set_play_type()
	    elif (opt == '-t'):
	        self.set_play_type(val)
	    elif opt[1] in 'xhH?':
		self.help()
		sys.exit(0)
	    elif opt[1] == '-d':
		self.debug = 1
			
    def help(self):
	print 'Supported types: (`file` pattern, name, cmd):'
	for patt, cmd in play_map:
	    name, cmds = cmd[0], cmd[1]
	    print "\t'%s' ('%s') --> %s" % (patt, name, cmds)

    def set_play_type(self, forced_type=None):
	if not self.get_file() :
	    self.play_cmd = ''
	    return

	p = os.popen('file %s' % self.get_file(), 'r')
	l = p.readline()
	p.close()
	ll = string.split(l)
	l = string.join(ll[1:])
	for patt, cmd in play_map:
	    p = regex.compile(patt)
	    if (p.search(l) >= 0):
		self.play_cmd = cmd[1]
		self.set_title(cmd[0])
		return
	self.play_cmd = ''
	raise ValueError

    def play(self):
	if self.pid:
		#print 'player busy'
		self.stop_player()
		#return

	if self.play_cmd == '':
	    self.set_play_type()
	    #print 'play_cmd>%s<' % self.play_cmd

	if self.play_cmd != '':
	    self.pid = os.fork()
	    if self.pid == 0:
		args = string.split(self.play_cmd % self.get_file())
		os.execvp(args[0], args)
		#print "done"
	    else:
		## python (or Tk) won't deliver signals till some
		## other event happens
		self.ticker()
		self.play_button_to_stop()# orig process

    def play_event(self, event):
	self.play()

    def get_file(self):
	return self.select_e.get()

    def set_file(self, name=None):
	self.select_e.delete('@0', END)
	self.select_e.insert('@0', name)

    def save_as(self):
	d = FileDialog.SaveFileDialog(self)
	file = d.go(self.select_path,
		      self.select_filter, '', 'get-file')
	if not file is None:
	    os.system('cp %s %s' % (self.get_file(), file))

    def select(self):
	d = FileDialog.LoadFileDialog(self)
	file = d.go(self.select_path,
		    self.select_filter, '', 'get-file')
	if not file is None:
	    self.set_file(file)
	    self.set_play_type()

    def file_event(self, event):
	self.select()

    def create_file_frame(self):
	f = self.file_frame = Frame(self)
	f.pack(side=LEFT, expand=YES, fill=X)
	self.select_b = Button(f, text="File:", 
			       command=self.select)
	self.select_b.pack(side=LEFT)
	self.select_e = Entry(f)
	self.select_e.bind('<Return>', self.play_event)
	self.select_e.pack(side=LEFT, fill=X, expand=TRUE)
	    
    def edit_play_cmd(self):
	e = editone_a.EditOne(self, self.play_cmd, 'Cmd', 'Enter Play Cmd')
	t = e.go()
        if t:
            self.play_cmd = t

    def create_menubar(self):
	mb = self.menubar = Frame(self, relief=RAISED, bd=2, 
				  cursor='hand2')
	mb.pack(side=TOP, expand=YES, fill=X)
	self.file_menu_b = Menubutton(mb, text='File', underline=0)
	self.file_menu_b.pack(side=LEFT)
	menu = Menu(self.file_menu_b)
	menu.add_command(label="Open...", command=self.select)
	menu.add_command(label="Save As...", command=self.save_as)
	menu.add_command(label="Play cmd...", command=self.edit_play_cmd)
	menu.add_separator()
	menu.add_command(label="Stop", command=self.stop_player)
	menu.add_separator()
	menu.add_command(label="Exit", 
			 command=lambda o=self: \
			 Application.quit_event(o, fake_event('x')))
	menu.add_command(label="Quit", 
			 command=lambda o=self: \
			 Application.quit_event(o, fake_event('q')))
	self.file_menu_b['menu'] = menu
	    
    def create_widgets(self):
	self.create_menubar()
	self.play_b = Button(self, text="Play", 
			     command=self.play, cursor='box_spiral')
	self.play_b.pack(side=LEFT)
	self.quit_b = Button(self, text="Quit", 
			     cursor='pirate',
			     command=self.my_quit)
	self.quit_b.pack(side=RIGHT)
	self.create_file_frame()
	
#
###################################
#
app = Application()
app.mainloop()
