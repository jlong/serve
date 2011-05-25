require 'serve/view_helpers'
require 'tilt'

module Serve #:nodoc:
  class DynamicHandler < FileTypeHandler #:nodoc:
    
    def self.extensions
      # Get extensions from Tilt, ugly but it works
      @extensions ||= (Tilt.mappings.map { |k,v| ["#{k}", "html.#{k}"] } << ["slim", "html.slim"]).flatten
    end
    
    def extensions
      self.class.extensions
    end
    
    extension *extensions
    
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
        possible_layouts = extensions.map do |ext|
          l = "_layout.#{ext}"
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
        context.singleton_class.module_eval(File.read(view_helpers_file_path) + "\ninclude ViewHelpers", view_helpers_file_path)
      end
    end
    
    class Parser #:nodoc:
      attr_accessor :context, :script_filename, :script_extension, :engine
      
      def initialize(context)
        @context = context
        @context.parser = self
      end
      
      def parse_file(filename, locals={})
        old_script_filename, old_script_extension, old_engine = @script_filename, @script_extension, @engine
        
        @script_filename = filename
        
        ext = File.extname(filename).sub(/^\.html\.|^\./, '').downcase
        
        if ext == 'slim' # Ugly, but works
          if Thread.list.size > 1
            warn "WARN: serve autoloading 'slim' in a non thread-safe way; " +
                 "explicit require 'slim' suggested."
          end
          require 'slim'  
        end
        
        @script_extension = ext
        
        @engine = Tilt[ext].new(filename, nil, :outvar => '@_out_buf')
        
        raise "#{ext} extension not supported" if @engine.nil?
        
        @engine.render(context, locals) do |*args|
          context.get_content_for(*args)
        end
      ensure
        @script_filename = old_script_filename
        @script_extension = old_script_extension
        @engine = old_engine
      end
      
    end
    
    class Context #:nodoc:
      attr_accessor :content, :parser
      attr_reader :request, :response
      
      def initialize(root_path, request, response)
        @root_path, @request, @response = root_path, request, response
        @content = ''
      end
      
      include Serve::ViewHelpers
    end
  end
end
