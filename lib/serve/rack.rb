require 'active_support'
require 'serve'
require 'rack'

module Serve
  class Rack
    def call(env)
      path = Serve.resolve_file(Dir.pwd, env["PATH_INFO"])
      return not_found unless path

      ext = File.extname(path)[1..-1]
      handler = Serve::FileTypeHandler.handlers[ext]
      return no_handler(ext) unless handler

      res = Response.new
      handler.new(Dir.pwd, path).process(nil, res)
      [200, res.headers, res.body]
    rescue Exception => e
      return html_response(500, %(
<h1>Error!</h1>
<h2>#{h(e.message)}</h2>
<pre>
#{h(e.backtrace.join("\n"))}
</pre>))
    end
    
    def no_handler(ext)
      html_response(501, %(
<h1>No handler</h1>

<p>Don't know how to handle resources of type "#{h(ext)}".</p>))
    end
    
    def not_found
      html_response(404, %(
<h1>Not Found</h1>

<p>The requested resource was not found.</p>))
    end
    
    def html_response(code, body)
      [code, {"Content-Type" => "text/html"}, %(<html><head></head><body>#{body}</body></html>)]
    end
    
    def h(input)
      CGI.escapeHTML(input)
    end
    
    class Response
      attr_reader :headers
      attr_accessor :body
      def initialize
        @headers = {}
      end
    end
  end
end
