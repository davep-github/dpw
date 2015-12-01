#!/usr/bin/env ruby

require 'ftools'

require 'rdoc/options'
require 'rdoc/template'
require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_flow'
require 'cgi'

require 'rdoc/ri/ri_cache'
require 'rdoc/ri/ri_reader'
require 'rdoc/ri/ri_writer'
require 'rdoc/ri/ri_descriptions'

require 'pp'

module RDoc
  class ClassModule
    # FIXME - I don't think this works...
    def file_name
      if @parent.class === TopLevel
        @parent.file_absolute_name
      else
        @parent.file_name
      end
    end
  end
  class AnyMethod
    # Collect all the tokens for the method up-to and including the identifier, 
    and the filename.
      def decl_string_and_file
        src = ''
        filename = nil
        break_on_nl = false
        if @token_stream
          @token_stream.each do |t|
            next unless t
            case t
            when RubyToken::TkCOMMENT
              # TkCOMMENT.text is "# File vpim/maker/vcard.rb, line 29"
              if( t.text =~ /# File (.*), line \d+/ )
                filename = $1
              end
            when RubyToken::TkNL
              break if break_on_nl
              src = ''
              
            else
              src << t.text
            end
            break_on_nl = true if RubyToken::TkIDENTIFIER === t
          end
          if false
            puts "----------------------"
            pp @token_stream
            puts "+++"
            puts src
            puts "----------------------"
          end
        end
        [ src, filename ]
      end
    end
  end
  
  module Generators
    
    
    class TAGSGenerator
      
      # Generators may need to return specific subclasses depending
      # on the options they are passed. Because of this
      # we create them using a factory
      
      def TAGSGenerator.for(options)
        new(options)
      end
      
      class <<self
        protected :new
      end
      
      # Set up a new HTML generator. Basically all we do here is load
      # up the correct output temlate
      
      def initialize(options) #:not-new:
        @options   = options
        
        # TODO - make this a command-line option
        @gen_qualified = true
        
        # TODO - make this a command-line option
        @gen_unqualified = false
        
        # TODO - make this a command-line option
        @output = File.open("tags.rdoc", 'w')
        
        # TODO - make this a command-line option
        @dump = nil # File.open("rdoc.dump", 'w')
        
        # TODO - make  this a command-line option
        @verbose = nil
        
        #pp options
      end
      
      
      def generate(toplevels)
        # This takes +8 minutes on vPim! Wow!
        PP.pp( toplevels, @dump ) if @dump
        
        RDoc::TopLevel.all_classes_and_modules.each do |cls|
          process_class(cls)
        end
      end
      
      def process_class(from_class)
        generate_class_info(from_class)
        
        # now recure into this classes constituent classess
        from_class.each_classmodule do |mod|
          process_class(mod)
        end
      end
      
      def generate_class_info(cls)
        # TODO:
        #  - when generating qualified names, generate the intermediate qualified as
        well, so
        #    all of these:
        #       Outer.Middle.Inner.a_method
        #       Middle.Inner.a_method
        #       Inner.a_method
        #       a_method
        
        =begin
           # TODO: can't do classes and modules, we don't have the original text tokens
           to reconstruct
           # the tag's REGEX.
           if cls === RDoc::NormalModule
             tag_type = 'c'
           else
             tag_type = 'm'
           end
           
           @output.puts tag = "#{cls.name}\t#{cls.file_name}\t/^class *#{cls.name}/;"\t
           #{tag_type}"
           
           if @gen_qualified && cls.name != cls.full_name
             @output.puts "#{cls.full_name.gsub('::', '.')}\t#{cls.file_name}\t/^class *#
{cls.name}/;\"\t#{tag_type}"
           end
           =end
        
        cls.method_list.each do |m|
          if m.singleton
            tag_type = 'F'
          else
            tag_type = 'f'
          end
          
          decl_string, decl_file = m.decl_string_and_file
          
          puts "Tagging: #{m.name} in: #{cls.full_name} from: #{decl_file}" if @verbos
          e
          
          tag = "#{m.name}\t#{decl_file}\t/^#{decl_string}$/;\"\t#{tag_type}"
          
          if @gen_unqualified
            @output.puts tag
          end
          if @gen_qualified
            path = cls.full_name.split('::')
            (1..path.length).each do |elements|
              qualifier = path[-elements, elements].join('.')
              
              puts "  ..#{qualifier}" if @verbose
              
              @output.puts "#{qualifier}.#{tag}"
            end
          end
        end
        
        # TODO: It would be great to tag attributes and contstants
        #     cls.attributes.each do |a|
        #     cls.constants.each do |c|
      end
      
    end
  end
end
