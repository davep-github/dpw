#!/usr/bin/env python

# -I /home/davep/bin

import os, sys, string, re, tempfile, fnmatch
from Tkinter import *
from opts import *
import Image
import ImageTk

opts = [
    # opt-char, opt-name, if-set-val, default-val, help-string
    FlagOption('r', 'no_rotate', 1, 0, 'do not rotate'),
    
    # opt-char, opt-name, how-to-set, default-val, help-string
    ArgOption('p', 'pic_dir', None, '.' , 'pic source dir'),
    ArgOption('t', 'thumb_dir', None, '.', 'thumbnail dest dir'),
    ArgOption('v', 'view_size', None, 160, 'image view size'),
    ArgOption('s', 'thumb_size', None, 80, 'thumbname size'),
    ArgOption('f', 'filter', None, '*.jpg', 'file selection filter')
    ]

# print 'tempfile.tempdir:', tempfile.tempdir
if (tempfile.tempdir == '/var/tmp') or (tempfile.tempdir == None):
    tempfile.tempdir = '/usr/tmp'

DELETED = 'red'
DELETED_SEL = 'purple'
SELECTED = 'blue'
UNSELECTED = 'gray'

# rotated/final pics
rpics = []

def scale_pil_image(image, scale):
    (x, y) = image.size
    x = int(x * scale)
    y = int(y * scale)
    return image.resize((x, y))

class TempFile:
    def __init__(self, ext='.ppm'):
        self.pathname = tempfile.mktemp('-mkt' + ext)

    def path(self):
        return self.pathname

    def __del__(self):
        os.system('rm -f %s' % self.pathname)
        
def get_image_dimensions(path):
    cmd = 'xli -identify %s' % path
    f = os.popen(cmd)
    resp = f.read()
    print 'resp:', resp
    f.close()
    m = re.search('(\d+)x(\d+)', resp)
    if m:
        return (m.group(1), m.group(2))
    else:
        raise "Bad xli identify output."

def scale_for(path, desired_max):
    x, y = get_image_dimensions(path)
    if x>y:
        max = x
    else:
        max = y
        
    return float(desired_max) / float(max)


class ImageInfo:
    def __init__(self, path):
        self.path = path
        self.image = None
        self.tag = None
        self.photo = None
        self.deleted = None
        self.rotated = 0

    def rotate(self, deg):
        """track total rotation, normalized to 0..359"""
        self.rotated += deg
        self.rotated %= 360

def bbbutton(win, text, cmd):
    """A little helper func to make a 'standard' button"""
    b = Button(win, text=text, command=cmd)
    b.pack(side=LEFT, expand=TRUE)
    return b

class ImageList(Frame):
    def __init__(self, pic_dir, master=None):
        Frame.__init__(self, master)
        self.pic_dir = pic_dir
        self.master = master
        self.f = Frame(self)
        self.f.pack(expand=TRUE, fill=BOTH)
        self.image_refs = []
        self.scroll = Scrollbar(self.f)
        self.scroll.pack(side=LEFT, fill=Y)
        self.text = Text(self.f, setgrid=TRUE, relief=GROOVE,
                         yscrollcommand=self.scroll.set)
        self.text.pack(side=TOP, expand=TRUE, fill=BOTH)
        self.scroll['command'] = self.text.yview

        self.bbar = Frame(self.f)
        bbbutton(self.bbar, 'Quit', self.quit_fn)
        bbbutton(self.bbar, 'Done', self.done_fn)
        self.bbar.pack(side=BOTTOM, expand=FALSE, fill=X)
        
        self.text.focus()
        for k in ('Control-q',  'Control-c', 'q', 'c'):
            self.text.bind('<%s>' % k, self.exit_fn)
            
        for k in ('Control-d', 'Control-x', 'd', 'x'):
            self.text.bind('<%s>' % k, self.delete_cur)
                
        self.text.bind('<r>', self.rotate_event_90)
        self.text.bind('<l>', self.rotate_event_270)
                
        self.text.bind('<Right>', self.move_right)
        self.text.bind('<Left>', self.move_left)
        
        self.image_info = []
        self.cur_choice = None
        self.pack(expand=TRUE, fill=BOTH)

    def rotate_event_90(self, event=None):
        self.rotate(degrees=90)

    def rotate_event_270(self, event=None):
        self.rotate(degrees=270)
        
    def move_left(self, event=None):
        self.move_cur(-1)

    def move_right(self, event=None):
        self.move_cur(1)

    def done_fn(self, event=None):
        global rpics
        rpics = []
        for ii in self.image_info:
            if not ii.deleted:
                rpics.append((os.path.basename(ii.path), ii.rotated))
          
        self.quit()

    def quit_fn(self, event=None):
        sys.exit(2)

    def exit_fn(self, event=None):
        sys.exit(2)
      
    def mk_display_thumb(self, ii):
        #
        # use this if no jpeg support is compiled into PIL
        #
        # tfo = TempFile()
        # tmp_file = tfo.path()
        # cmd = 'jpegtopnm %s > %s' % (ii.path, tmp_file)
        # print cmd
        # rc = os.system(cmd)
        # if rc:
        #     raise 'cmd>%s< failed.' % cmd

        tmp_file = ii.path
        ii.pil_image = Image.open(tmp_file)
        # print 'format:', ii.pil_image.format
        # print 'mode:', ii.pil_image.mode
        # print 'info:', ii.pil_image.info
        scale = scale_for(ii.path, options.view_size)
        ii.pil_image = scale_pil_image(ii.pil_image, scale)
        ii.photo = ImageTk.PhotoImage(ii.pil_image)

    def rotate(self, image_info=None, degrees=90):
        """make a new preview thumb and display it"""
        if image_info == None:
            image_info = self.cur_choice
        if image_info == None:
            return

        image_info.pil_image = image_info.pil_image.rotate(360-degrees)
        image_info.rotate(degrees)      # keep track of total rotation
        image_info.photo = ImageTk.PhotoImage(image_info.pil_image)
        self.text.image_configure(image_info.tag, image=image_info.photo)

    def move_cur(self, num):
        if self.cur_choice:
            idx = self.image_info.index(self.cur_choice)
            idx = (idx + num) % len(self.image_info)
        else:
            idx = 0
        self.choose(self.image_info[idx])
			   
    def delete_cur(self, event=None):
        if self.cur_choice:
            self.cur_choice.deleted = not self.cur_choice.deleted
            if self.cur_choice.deleted:
                self.set_image_bg(self.cur_choice, DELETED_SEL)
            else:
                self.set_image_bg(self.cur_choice, SELECTED)

    def set_image_bg(self, image_info, bg):
        self.text.tag_configure(image_info.tag, background=bg)
      
    def choose(self, image_info):
        #
        # set bg of old current item
        #
        if self.cur_choice:
            if self.cur_choice.deleted:
                self.set_image_bg(self.cur_choice, DELETED)
            else:
                self.set_image_bg(self.cur_choice, UNSELECTED)

        self.cur_choice = image_info
      
        #
        # set bg of new current item
        #
        if self.cur_choice.deleted:
            self.set_image_bg(self.cur_choice, DELETED_SEL)
        else:
            self.set_image_bg(self.cur_choice, SELECTED)

    def tagit(self, ii):
        tag_name = ii.image
        ii.tag = tag_name
        # print 'pp>%s<, index>%s<' % (tag_name, image)
        self.text.tag_add(tag_name, '%s' % ii.image)
        # print 'self in tagit:', self
        self.text.tag_bind(tag_name, "<Double-1>",
                           lambda r, f=self.rotate, ii=ii: f(ii))
        self.text.tag_bind(tag_name, "<Button-2>",
                           lambda r, f=self.rotate, d=270, ii=ii: f(ii, 270))
        self.text.tag_bind(tag_name, "<Button-1>",
                           lambda e,f=self.choose, ii=ii: f(ii))

    def add_pics(self, pic_names):
        for pic_name in pic_names:
            pic_path = self.pic_dir + "/" + pic_name
            ii = ImageInfo(pic_path)
            self.image_info.append(ii)
            
            # print "read %s" % pic_path
            self.mk_display_thumb(ii)
            ii.image = self.text.image_create(END, image=ii.photo,
                                              padx=4, pady=4)
            # print 'new image:', image, 'image names:', self.text.image_names()
            self.tagit(ii)
            self.text.insert(END, pic_name)

    def disable_input(self):
        self.text.configure(state=DISABLED)

    def enable_input(self):
        self.text.configure(state=NORMAL)

def tkrotate(pics, pic_dir):
    """Create a tk app to display pics and allow user to select rotations."""
    master = Tk()
    ilist = ImageList(pic_dir, master)
    ilist.add_pics(pics)
    ilist.disable_input()
    master.title("thumbnailer")
    master.mainloop()
    return rpics


def list_images(dir):
    tpics = os.listdir(dir)
    # print 'dir:', dir, 'tpics:', tpics
    pics = []
    filter = options.filter
    for pic in tpics:
        # print 'ext:', pic[-4:]
        if fnmatch.fnmatch(pic, filter):
            pics.append(pic)
    del(tpics)
    pics.sort()
    return pics
    

options = Options(sys.argv, opts)

pics = list_images(options.pic_dir)
      
# get listing of thumb dir
thumbs = list_images(options.thumb_dir)

# for all in pic and not in thumb
new_pics = []
for pic in pics:
    if pic not in thumbs:
        new_pics.append(pic)
print 'pics:', pics
print 'thumbs:', thumbs
print 'new_pics:', new_pics

Image.init()

#
# Now, display them all in a tk window and allow us to select and
# rotate them
#
if not options.no_rotate:
    new_pics = tkrotate(new_pics, options.pic_dir)
    print 'new_pics:', new_pics

#
# now make real thumbnails
#

for pic, degrees in new_pics:
    sfile = options.pic_dir + "/" + pic
    dfile = options.thumb_dir + "/" + pic
    # printf("scale %s into %s\n", sfile, dfile)
    scale = scale_for(sfile, options.thumb_size)
    if degrees:
        rot_cmd = 'jpegtran -rotate %s %s | djpeg' % (degrees, sfile)
    else:
        rot_cmd = 'djpeg %s' % sfile
    print "scale %f %s\n" % (scale, sfile)
    cmd = "%s | pnmscale %s | cjpeg -quality 100 > %s" % (rot_cmd,
                                                               scale,
                                                               dfile)
    print "cmd:", cmd

    rc = os.system(cmd)
    if rc:
        raise 'cmd>%s< failed.' % cmd

sys.exit(0)



#          tfo = TempFile()
#          tmp_file = tfo.path()
#          if image_info == None:
#              image_info = self.cur_choice

#          if not image_info:
#              return

#          path = image_info.path
#          image = image_info.image

#          # rotate the original, since we want that corrected, too.
#          cmd = "jpegtran -rotate %s %s > %s" % (degrees, path, tmp_file)
#          # print 'cmd:', cmd
#          rc = os.system(cmd)
#          if rc:
#              raise 'cmd>%s< failed.' % cmd
#          cmd = "cp -f %s %s" % (tmp_file, path)
#          # print 'cmd:', cmd
#          rc = os.system(cmd)
#          if rc:
#              raise 'cmd>%s< failed.' % cmd
