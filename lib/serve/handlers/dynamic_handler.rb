require 'serve/view_helpers'

module Serve #:nodoc:
  class DynamicHandler < FileTypeHandler #:nodoc:
    extension 'erb', 'html.erb', 'rhtml', 'haml', 'html.haml'
    
    def process(request, response)
      response.headers['content-type'] = content_type
      response.body = parse(request, response)
    end
    
    def parse(request, response)
      context = Context.new(@root_path, request, response)
      install_view_helpers(context)
      parser = Parser.new(context)
      context.content << parser.parse_file(@script_filename)
      layout = find_layout_for(@script_filename)
      if layout
        parser.parse_file(layout)
      else
        context.content
      end
    end
    
    def find_layout_for(filename)
      root = @root_path
      path = filename[root.size..-1]
      layout = nil
      until layout or path == "/"
        path = File.dirname(path)
        possible_layouts = ['_layout.haml', '_layout.html.haml', '_layout.erb', '_layout.html.erb'].map do |l|
          possible_layout = File.join(root, path, l)
          File.file?(possible_layout) ? possible_layout : false
        end
        layout = possible_layouts.detect { |o| o }
      end
      layout
    end
    
    def install_view_helpers(context)
      view_helpers_file_path = @root_path + '/view_helpers.rb'
      if File.file?(view_helpers_file_path)
        context.metaclass.module_eval(File.read(view_helpers_file_path) + "\ninclude ViewHelpers", view_helpers_file_path)
      end
    end
    
    module ERB #:nodoc:
      class Engine #:nodoc:
        def initialize(string, options = {})
          @erb = ::ERB.new(string, nil, '-', '@erbout')
          @erb.filename = options[:filename]
        end
        
        def render(context, &block)
          # we have to keep track of the old erbout variable for nested renders
          # because ERB#result will set it to an empty string before it renders
          old_erbout = context.instance_variable_get('@erbout')
          result = @erb.result(context.instance_eval { binding })
          context.instance_variable_set('@erbout', old_erbout)
          result
        end
      end
    end
    
    class Parser #:nodoc:
      attr_accessor :context, :script_filename
      
      def initialize(context)
        @context = context
        @context.parser = self
      end
      
      def parse_file(filename)
        old_script_filename = @script_filename
        @script_filename = filename
        lines = IO.read(filename)
        engine = case File.extname(filename).sub(/^./, '').downcase
          when 'haml'
            require 'haml'
            require 'sass'
            require 'sass/plugin'
            Haml::Engine.new(lines, :attr_wrapper => '"', :filename => filename)
          when 'erb'
            require 'erb'
            ERB::Engine.new(lines, :filename => filename)
          else
            raise 'extension not supported'
        end
        result = engine.render(context) do |*args|
          context.get_content_for(*args)
        end
        @script_filename = old_script_filename
        result
      end
    end
    
    class Context #:nodoc:
      attr_accessor :content, :parser
      attr_reader :request, :response
      
      def initialize(root_path, request, response)
        @root_path, @request, @response = root_path, request, response
        @content = ''
      end
      
      def _erbout
        @erbout
      end
      
      include Serve::ViewHelpers
    end
  end
end