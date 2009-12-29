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
    
    def self.find(path)
      if ext = File.extname(path)
        handlers[ext.sub(/\A\./, '')]
      end
    end
    
    def initialize(root_path, path)
      @root_path = root_path
      @script_filename = File.join(@root_path, path)
    end
    
    def process(request, response)
      response.headers['content-type'] = content_type
      response.body = parse(open(@script_filename){|io| io.read })
    end
    
    def content_type
      'text/html'
    end
    
    def parse(string)
      string.dup
    end
  end
end