require 'serve/version'
require 'webrick/extensions'

module Serve #:nodoc:
  class FileTypeHandler < WEBrick::HTTPServlet::AbstractServlet #:nodoc:
    
    def self.extension(extension)
      WEBrick::HTTPServlet::FileHandler.add_handler(extension, self)
    end
    
    def initialize(server, name)
      super
      @script_filename = name
    end
    
    def process(req, res)
      data = open(@script_filename){|io| io.read }
      res['content-type'] = content_type
      res.body = parse(data)
    end
    
    def do_GET(req, res)
      begin
        process(req, res)
      rescue StandardError => ex
        raise
      rescue Exception => ex
        @logger.error(ex)
        raise WEBrick::HTTPStatus::InternalServerError, ex.message
      end
    end
    
    alias do_POST do_GET
    
    protected
    
      def content_type
        'text/html'
      end
      
      def parse(string)
        string.dup
      end
      
  end
  
  class TextileHandler < FileTypeHandler #:nodoc:
    extension 'textile'
    
    def parse(string)
      require 'redcloth'
      "<html><body>#{ RedCloth.new(string).to_html }</body></html>"
    end
  end
  
  class MarkdownHandler < FileTypeHandler #:nodoc:
    extension 'markdown'
    
    def parse(string)
      require 'bluecloth'
      "<html><body>#{ BlueCloth.new(string).to_html }</body></html>"
    end
  end
  
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
    
    class Context
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
  
  class SassHandler < FileTypeHandler #:nodoc:
    extension 'sass'
    
    def parse(string)
      require 'sass'
      engine = Sass::Engine.new(string,
        :style => :expanded,
        :filename => @script_filename
      )
      engine.render 
    end
    
    def content_type
      'text/css'
    end
  end
  
  class EmailHandler < FileTypeHandler #:nodoc:
    extension 'email'
    
    def parse(string)
      title = "E-mail"
      title = $1 + " #{title}" if string =~ /^Subject:\s*(\S.*?)$/im
      head, body = string.split("\n\n", 2)
      output = []
      output << "<html><head><title>#{title}</title></head>"
      output << '<body style="font-family: Arial; line-height: 1.2em; font-size: 90%; margin: 0; padding: 0">'
      output << '<div id="head" style="background-color: #E9F2FA; padding: 1em">'
      head.each do |line|
        key, value = line.split(":", 2).map { |a| a.strip }
        output << "<div><strong>#{key}:</strong> #{value}</div>"
      end
      output << '</div><pre id="body" style="font-size: 110%; padding: 1em">'
      output << body
      output << '</pre></body></html>'
      output.join("\n")
    end
  end
  
  class RedirectHandler < FileTypeHandler  #:nodoc:
    extension 'redirect'
    
    def process(req, res)
      data = super
      res['location'] = data.strip
      res.body = ''
      raise WEBrick::HTTPStatus::Found
    end
  end
  
  class Server < WEBrick::HTTPServer #:nodoc:
  end
  
end
