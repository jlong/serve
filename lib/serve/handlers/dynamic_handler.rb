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
      
      # This is extracted from Rails
      def capture_erb(&block)
        buffer = _erbout
        pos = buffer.length
        block.call
        
        # extract the block 
        data = buffer[pos..-1]
        
        # replace it in the original with empty string
        buffer[pos..-1] = ''
        
        data
      end
      
      # Content_for methods
      
      def content_for(symbol, &block)
        if @haml_buffer
          set_content_for(symbol, capture_haml(&block))
        else
          set_content_for(symbol, capture_erb(&block))
        end
      end
      
      def content_for?(symbol)
        !(get_content_for(symbol)).nil?
      end
      
      def get_content_for(symbol = :content)
        if symbol.to_s.intern == :content
          @content
        else
          instance_variable_get("@content_for_#{symbol}")
        end
      end
      
      # View helper methods
      
      HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }
      def html_escape(s)
        s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
      end
      alias h html_escape
      
      def set_content_for(symbol, value)
        instance_variable_set("@content_for_#{symbol}", value)
      end
      
      def params
        request.params
      end
      
      # Render methods
      
      def render(options)
        partial = options.delete(:partial)
        template = options.delete(:template)
        case
        when partial
          render_partial(partial)
        when template
          render_template(template)
        else
          raise "render options not supported #{options.inspect}"
        end
      end
      
      def render_partial(partial)
        render_template(partial, :partial => true)
      end
      
      def render_template(template, options={})
        path = File.dirname(parser.script_filename)
        if template =~ %r{^/}
          template = template[1..-1]
          path = @root_path
        end
        filename = template_filename(File.join(path, template), :partial => options.delete(:partial))
        if File.file?(filename)
          parser.parse_file(filename)
        else
          raise "File does not exist #{filename.inspect}"
        end
      end
      
      private
      
        def template_filename(name, options)
          path = File.dirname(name)
          template = File.basename(name)
          template = "_" + template if options.delete(:partial)
          template += extname(parser.script_filename) unless name =~ /\.[a-z]{3,4}$/
          File.join(path, template)
        end
        
        def extname(filename)
          /(\.[a-z]{3,4}\.[a-z]{3,4})$/.match(filename)
          $1 || File.extname(filename) || ''
        end
    end
  end
end