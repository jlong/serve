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
        raise ::WEBrick::HTTPStatus::InternalServerError, ex.message
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
end