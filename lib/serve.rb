require 'serve/version'
require 'webrick/extensions'

module Serve
  class FileTypeHandler < WEBrick::HTTPServlet::AbstractServlet

    def self.extension(extension)
      WEBrick::HTTPServlet::FileHandler.add_handler(extension, self)
    end

    def initialize(server, name)
      super
      @script_filename = name
    end

    def do_GET(req, res)
      begin
        data = open(@script_filename){|io| io.read }
        res.body = parse(data)
        res['content-type'] = content_type
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

  class TextileHandler < FileTypeHandler
    extension 'textile'

    def parse(string)
      require 'redcloth'
      "<html><body>#{ RedCloth.new(string).to_html }</body></html>"
    end
  end

  class MarkdownHandler < FileTypeHandler
    extension 'markdown'

    def parse(string)
      require 'bluecloth'
      "<html><body>#{ BlueCloth.new(string).to_html }</body></html>"
    end
  end

  class HamlHandler < FileTypeHandler
    extension 'haml'

    def parse(string)
      require 'haml'
      engine = Haml::Engine.new(string,
        :attr_wrapper => '"',
        :filename => @script_filename
      )
      engine.render 
    end
  end

  class SassHandler < FileTypeHandler
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
  
  class Server < WEBrick::HTTPServer
  end
  
end