require 'serve/view_helpers'

module Serve
  class Pipeline
    def self.handles?(path)
      !FileTypeHandler.handlers_for(path).empty?
    end

    def self.build(root, path)
      return nil unless handles?(path)
      Pipeline.new(root, path, extensions_for(path))
    end
    
    attr_reader :template
    def initialize(root_path, path)
      @root_path = root_path
      @template = Template.new(File.join(@root_path, path))
      @layout = find_layout_for(@template.path)
    end

    def find_layout_for(template_path)
      return Template::Passthrough.new(@template) unless @template.layout?
      root = @root_path
      path = template_path[root.size..-1]
      layout = nil
      until layout or path == "/"
        possible_layouts = FileTypeHandler.extensions.map do |ext|
          l = "_layout.#{ext}"
          possible_layout = File.join(root, path, l)
          File.file?(possible_layout) ? possible_layout : false
        end
        layout = possible_layouts.detect { |o| o }
        path = File.dirname(path)
      end
      if layout
        Template.new(layout)
      else
        Template::Passthrough.new(@template)
      end
    end
    
    def process(request, response)
      response.headers['Content-Type'] = @layout.content_type
      context = Context.new(@root_path, request, response)
      @template.process(context)
      @layout.process(context)
      response.body = context.content
    end

    class Template
      attr_reader :path, :handlers
      def initialize(file)
        @path = File.dirname(file)
        @raw = File.read(file)
        @handlers = FileTypeHandler.handlers_for(file).collect{|h, extension| h.new(@root_path, @path, extension)}
      end

      def content_type
        @handlers.first.content_type
      end

      def process(context)
        context.content = @handlers.reverse.inject(@raw.dup) do |body, handler|
          handler.process(body, context)
        end
      end

      def layout?
        @handlers.first.layout?
      end

      class Passthrough
        def initialize(template)
          @template = template
        end

        def process(context)
        end

        def layout?
          false
        end

        def content_type
          @template.content_type
        end
      end
    end

    class Context #:nodoc:
      attr_accessor :content, :parser
      attr_reader :request, :response
      
      def initialize(root_path, request, response)
        @root_path, @request, @response = root_path, request, response
        @content = ''
        install_view_helpers
      end
      
      def install_view_helpers
        view_helpers_file_path = @root_path + '/view_helpers.rb'
        if File.file?(view_helpers_file_path)
          singleton_class.module_eval(File.read(view_helpers_file_path) + "\ninclude ViewHelpers", view_helpers_file_path)
        end
      end
      
      include Serve::ViewHelpers
    end
  end
end