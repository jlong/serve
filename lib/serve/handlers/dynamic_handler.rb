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
    
    extension(*extensions)
    
    def parse(input, context)
      parser = Parser.new(context, @template_path)
      parser.parse(input, extension)
    end
    
    class Parser #:nodoc:
      attr_accessor :context, :script_extension, :engine, :template_path
      
      def initialize(context, template_path)
        @context = context
        @context.parser = self
        @template_path = template_path
      end
      
      def parse(input, ext, locals={})
        old_script_extension, old_engine = @script_extension, @engine

        if ext == 'slim' # Ugly, but works
          if Thread.list.size > 1
            warn "WARN: serve autoloading 'slim' in a non thread-safe way; " +
                 "explicit require 'slim' suggested."
          end
          require 'slim'  
        end
        
        @script_extension = ext
        
        @engine = Tilt[ext].new(nil, nil, {:outvar => '@_out_buf'}.merge(FileTypeHandler.options_for(ext))){input}
        
        raise "#{ext} extension not supported" if @engine.nil?
        
        @engine.render(context, locals) do |*args|
          context.get_content_for(*args)
        end
      ensure
        @script_extension = old_script_extension
        @engine = old_engine
      end
    end
  end
end
