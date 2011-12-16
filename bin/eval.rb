require "readline"
include Readline

line = ''
indent=0
$stdout.sync = TRUE
# print "ruby> "
prompt="ruby> "
while TRUE
  l = readline(prompt, 1)
  #print ">#{l}<"
  unless l
    break if line == ''
  else
    l += "\n"
    line = line + l
    if l =~ /,\s*$/
      print "ruby| "
      next
    end
    if l =~ /^\s*(class|module|def|if|unless|case|while|until|for|begin)\b[^_]/
      indent += 1
    end
    if l =~ /^\s*end\b[^_]/
      indent -= 1
    end
    if l =~ /\{\s*(\|.*\|)?\s*$/
      indent += 1
    end
    if l =~ /^\s*\}/
      indent -= 1
    end
    if indent > 0
      prompt = "ruby| "
      next
    end
  end
  begin
    print eval(line).inspect, "\n"
  rescue
    $! = 'exception raised' unless $!
    print "ERR: ", $!, "\n"
  end
  break if not l
  line = ''
  prompt = "ruby> "
end
print "\n"
