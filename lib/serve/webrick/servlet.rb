module Serve #:nodoc:
  module WEBrick
    class Servlet < ::WEBrick::HTTPServlet::AbstractServlet #:nodoc:
      def do_GET(req, res)
        begin
          path = Serve.resolve_file(Dir.pwd, req.path)
          handler.new(Dir.pwd, path).process(req, res)
        rescue StandardError => ex
          raise
        rescue Exception => ex
          @logger.error(ex)
          raise ::WEBrick::HTTPStatus::InternalServerError, ex.message
        end
      end
      
      alias do_POST do_GET
    end
  end
end