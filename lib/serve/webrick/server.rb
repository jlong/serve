module Serve #:nodoc:
  module WEBrick
    class Server < ::WEBrick::HTTPServer #:nodoc:
      def self.register_handlers
        extensions = []
        Serve::FileTypeHandler.handlers.each do |ext, handler|
          extensions << ext
          handler_servlet = Class.new(Serve::WEBrick::Servlet) do
            define_method(:handler) { handler }
          end
          ::WEBrick::HTTPServlet::FileHandler.add_handler(ext, handler_servlet)
        end
        extensions
      end
    end
  end
end