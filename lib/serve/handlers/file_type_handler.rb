module Serve #:nodoc:
  class FileTypeHandler #:nodoc:
    def self.handlers
      @handlers ||= {}
    end
    
    def self.extension(*extensions)
      extensions.each do |ext|
        FileTypeHandler.handlers[ext] = self
      end
    end

    def self.extensions
      handlers.keys
    end

    def self.handlers_for(path)
      extensions = File.basename(path).split(".")[1..-1]
      extensions.collect{|e| [handlers[e], e] if handlers[e]}.compact
    end

    def self.configure(extension, options)
      extension_options[extension.to_sym].merge!(options)
    end

    def self.extension_options
      @extension_options ||= Hash.new{|h,k| h[k] = {}}
    end

    def self.options_for(extension)
      extension_options[extension.to_sym]
    end

    attr_reader :extension
    def initialize(root_path, template_path, extension)
      @root_path = root_path
      @template_path = template_path
      @extension = extension
    end
    
    def process(input, context)
      parse(input, context)
    end
    
    def content_type
      'text/html'
    end

    def layout?
      true
    end
    
    def parse(input, context)
      input.dup
    end
  end
end
