module Serve #:nodoc:
  class HamlHandler < FileTypeHandler #:nodoc:
    extension 'haml'
  
    def parse(string)
      require 'haml'
      engine = Haml::Engine.new(string,
        :attr_wrapper => '"',
        :filename => @script_filename
      )
      layout = find_layout(@script_filename)
      if layout
        lines = IO.read(layout)
        context = Context.new(Dir.pwd, @script_filename, engine.options.dup)
        context.content = engine.render(context) do |*args|
          context.get_content_for(*args)
        end
        layout_engine = Haml::Engine.new(lines, engine.options.dup)
        layout_engine.render(context) do |*args|
          context.get_content_for(*args)
        end
      else
        engine.render
      end
    end
  
    def find_layout(filename)
      root = Dir.pwd
      path = filename[root.size..-1]
      layout = nil
      begin
        path = File.dirname(path)
        l = File.join(root, path, '_layout.haml')
        layout = l if File.file?(l)
      end until layout or path == "/"
      layout
    end
  
    class Context #:nodoc:
      attr_accessor :content
    
      def initialize(root, script_filename, engine_options)
        @root, @script_filename, @engine_options = root, script_filename, engine_options
      end
    
      # Content_for methods
    
      def content_for(symbol, &block)
        set_content_for(symbol, capture_haml(&block))
      end
    
      def content_for?(symbol)
        !(get_content_for(symbol)).nil?
      end
    
      def get_content_for(symbol = :content)
        if symbol.to_s.intern == :content
          @content
        else
          instance_variable_get("@content_for_#{symbol}") || instance_variable_get("@#{symbol}")
        end
      end
    
      def set_content_for(symbol, value)
        instance_variable_set("@content_for_#{symbol}", value)
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
        path = File.dirname(@script_filename)
        if template =~ %r{^/}
          template = template[1..-1]
          path = @root
        end
        filename = template_filename(File.join(path, template), :partial => options.delete(:partial))
        if File.file?(filename)
          lines = IO.read(filename)
          engine = Haml::Engine.new(lines, @engine_options)
          engine.render(self) do |*args|
            get_content_for(*args)
          end
        else
          raise "File does not exist #{filename.inspect}"
        end
      end
    
      def template_filename(name, options)
        path = File.dirname(name)
        template = File.basename(name)
        template = "_" + template if options.delete(:partial)
        template += ".haml" unless name =~ /\.haml$/
        File.join(path, template)
      end
    end
  end
end