#!/usr/env/ruby

# Edit a file from ruby/irb, and then eval the contents in the current
# environment.  Idea ripped off from IPython.

require "tempfile"

def edit(filename=nil, b=TOPLEVEL_BINDING, level=2)
  if (not filename)
    tfile = Tempfile.new("rbedit")
    filename = tfile.path
    tfile.close()
  end
  system("gnuclient #{filename}")

  # Works, but echoes every line.
  # look at @context.echo
  #irb_source(filename)

  b = conf.workspace.binding
  eval(open(filename).read(), b)
end
