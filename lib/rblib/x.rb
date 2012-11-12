load_file = "ima_load_file"
cmd_name = "a_cmd_name"
cmd_class = "a_cmd_class"

puts %[
  def #{cmd_name}(*opts, &b)
    require "#{load_file}"
    eval %[
      def #{cmd_name}(*opts, &b)
        ExtendCommand::#{cmd_class}.execute(irb_context, *opts, &b)
      end
    ]
    send :#{cmd_name}, *opts, &b
  end
]
        
