#!/usr/local/bin/ruby
# -I /home/davep/bin

require "tktext"
require "tempfile"
require "getoptlong"

PIC_DIR = '-p'
THUMB_DIR = '-t'
VIEW_SIZE = '-v'
THUMB_SIZE = '-s'
PRINT_OPTIONS = '-o'
NO_ROTATE = '-r'

DELETED = 'red'
DELETED_SEL = 'purple'
SELECTED = 'blue'
UNSELECTED = 'gray'

$options = {
  PIC_DIR => '/usr/tmp',
  THUMB_DIR => '/usr/tmp/thumbs',
  VIEW_SIZE => 160,
  THUMB_SIZE => 80,
  PRINT_OPTIONS => nil,
  NO_ROTATE => nil
}

# rotated/final pics
$rpics = []  
def get_tmp_file()
  f = Tempfile.new('mk-thumbs', '/usr/tmp')
  f.close()
  #p f.path
  return f
end

def image_dimensions(path)
  fail(format("no such file %s\n",path)) if !File.exist?(path)
  resp = `xli -identify #{path}`
  if resp =~ /is a (\d+)x(\d+)/
    return $1.to_i, $2.to_i
  else
    fail "Bad xli identify output."
  end
end

def scale_for(path, desired_max)
  x, y = image_dimensions(path)
  max = x > y ? x : y
  Float(desired_max) / Float(max)
end

class ImageInfo
  def initialize(path, image, tag)
    @path = path
    @image = image
    @tag = tag
    @deleted = nil
  end

  attr_reader(:path, :image, :tag)
  attr_accessor(:deleted)
end

class ImageList < TkFrame
  def initialize(pic_dir)
    @pic_dir = pic_dir
    @f = TkFrame.new(Tk.root)
    @f.pack('expand'=>'yes', 'fill'=>'both')

    @text = TkText.new(@f) {
      setgrid 'true'
      relief 'groove'
    }
    @text.pack('side'=>'left', 'expand'=>'yes', 'fill'=>'both')

    ybar = TkScrollbar.new(@f)
    ybar.pack('side'=>'left', 'expand'=>'no', 'fill'=>'y')
    @text.yscrollbar(ybar)

    @bbar = TkFrame.new(Tk.root)
    TkButton.new(@bbar) {
      text 'Quit'
      command proc{exit}
      pack('side'=>'left', 'expand'=>'yes')
    }

    d = proc{self.mydone}
    TkButton.new(@bbar) {
      text 'Done'
      command d
      pack('side'=>'left', 'expand'=>'yes')
    }
    @bbar.pack('side'=>'bottom', 'expand'=>'no', 'fill'=>'x')

    @text.focus
    for k in %w(Control-q Control-c q c)
      @text.bind(k, proc{exit})
    end
    for k in %w(Control-d Control-x d x)
      @text.bind(k, proc{self.delete_cur})
    end
    for k in %w(Control-u u)
      @text.bind(k, proc{self.delete_cur})
    end
    @text.bind('r', proc{self.rotate(nil, 90)})
    @text.bind('l', proc{self.rotate(nil, 270)})
    
    @text.bind('Right', proc{self.move_cur(1)})
    @text.bind('Left', proc{self.move_cur(-1)})

    
    @image_info = []
    @cur_choice = nil
  end

  def mydone()
    $rpics = []
    for ii in @image_info
      $rpics.push(File.basename(ii.path)) unless ii.deleted
    end
    Tk.root.destroy()
  end

  def mk_display_thumb(path)
    tmp_file0 = get_tmp_file()
    tmp_file = tmp_file0.path
    scale = scale_for(path, $options[VIEW_SIZE])
    system("djpeg #{path} | pnmscale #{scale} > #{tmp_file}")
    photo = TkPhotoImage.new('file'=>tmp_file)
    return photo
  end

  def rotate(image_info=nil, degrees=90)
    tmp_file0 = get_tmp_file()
    tmp_file = tmp_file0.path
    if image_info == nil
      image_info = @cur_choice
    end
    return if !image_info
    path = image_info.path
    image = image_info.image

    # rotate the original, since we want that corrected, too.
    cmd = "jpegtran -rotate #{degrees} #{path} > #{tmp_file}"
    #p cmd
    system(cmd)
    system("cp -f #{tmp_file} #{path}")

    # make a new preview thumb and display it
    image.image = mk_display_thumb(path)
  end

  def move_cur(num)
    if @cur_choice
      idx = @image_info.index(@cur_choice)
      idx = (idx + num) % @image_info.nitems()
    else
      idx = 0
    end
    choose(@image_info[idx])
  end
			   
  def delete_cur()
    if @cur_choice
      @cur_choice.deleted = !@cur_choice.deleted
      if @cur_choice.deleted
	@cur_choice.tag.configure('background'=>DELETED_SEL)
      else
	@cur_choice.tag.configure('background'=>SELECTED)
      end
    end
  end
      
  def choose(image_info)
    if @cur_choice
      if @cur_choice.deleted
	@cur_choice.tag.configure('background'=>DELETED)
      else
	@cur_choice.tag.configure('background'=>UNSELECTED)
      end
    end
    @cur_choice = image_info
    if @cur_choice.deleted
      @cur_choice.tag.configure('background'=>DELETED_SEL)
    else
      @cur_choice.tag.configure('background'=>SELECTED)
    end      
  end

  #
  # do this in a method so that the value
  # of ii is maintained correctly in the closure
  # for the tag bindings.
  # if it is in the add_pics method, then ii
  # is that last value in the pic_names
  # iteration
  #
  def tagit(pic_path, image)
      tag = TkTextTag.new(@text, image.path)
      ii = ImageInfo.new(pic_path, image, tag)
      @image_info.push(ii)
      tag.bind("Double-1", proc {self.rotate(ii)})
      tag.bind("Button-2", proc {self.rotate(ii, 270)})
      tag.bind("Button-1", proc {self.choose(ii)})
  end

  def add_pics(pic_names)
    for pic_name in pic_names
      pic_path = @pic_dir + "/" + pic_name
      printf("read %s\n", pic_path)
      photo = mk_display_thumb(pic_path)
      image = TkTextImage.new(@text, 'end', 
                              {'image'=>photo, 'padx'=>4, 'pady'=>4})

      tagit(pic_path, image)
    end
  end

  def disable_input()
    @text.configure('state'=>'disabled')
  end

  def enable_input()
    @text.configure('state'=>'normal')
  end

end

def tkrotate(pics, pic_dir)
  ilist = ImageList.new(pic_dir)
  ilist.add_pics(pics)
  ilist.disable_input()
  Tk.root.title("thumbnailer")
  Tk.mainloop()
  $rpics
end

begin

  parser = GetoptLong.new
  parser.set_options(
	[PIC_DIR, '--pic-dir', GetoptLong::REQUIRED_ARGUMENT],
	[THUMB_DIR, '--thumb-dir', GetoptLong::REQUIRED_ARGUMENT],
	[VIEW_SIZE, '--view-size', GetoptLong::REQUIRED_ARGUMENT],
	[THUMB_SIZE, '--thumb_size',GetoptLong::REQUIRED_ARGUMENT],
	[PRINT_OPTIONS, GetoptLong::NO_ARGUMENT])

  parser.each { |name, arg|
    $options[name] = arg
  }

  p $options if $options[PRINT_OPTIONS]

  back = Dir.pwd
  # get listing of pic dir
  Dir.chdir($options[PIC_DIR])
  pics = Dir["*.jpg"]

  Dir.chdir(back)

  # get listing of thumb dir
  Dir.chdir($options[THUMB_DIR])
  thumbs = Dir["*.jpg"]

  Dir.chdir(back)

  # for all in pic and not in thumb 
  new_pics = pics - thumbs
  #p pics
  #p thumbs
  #p new_pics

  #
  # Now, display them all in a tk window and allow us to select and
  # rotate them
  #
  new_pics = tkrotate(new_pics, $options[PIC_DIR]) unless $options[NO_ROTATE]

  #
  # now make real thumbnails
  #
  for pic in new_pics
    sfile = $options[PIC_DIR] + "/" + pic
    dfile = $options[THUMB_DIR] + "/" + pic
    #printf("scale %s into %s\n", sfile, dfile)
    scale = scale_for(sfile, $options[THUMB_SIZE])
    printf("scale %f %s\n", scale, sfile)
    cmd = "djpeg #{sfile} | pnmscale #{scale} | cjpeg -quality 100 > #{dfile}"
    #printf("%s\n", cmd)
    system(cmd)
  end

rescue
  printf($stderr, "I failed, %s.\n", Dir.pwd());
  fail
end

exit(0)
