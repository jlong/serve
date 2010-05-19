require 'rack'

module Serve
  class Request < Rack::Request
    def query
      @query ||= Rack::Utils.parse_nested_query(query_string)
    end
    def protocol
      scheme + "://"
    end
  end
  class Response < Rack::Response
  end
  
  class RackAdapter
    
    def initialize(root)
      @root = root
    end
    
    def call(env)
      request = Request.new(env)
      response = Response.new()
      process(request, response).to_a
    end
    
    def process(request, response)
      path = Serve.resolve_file(@root, request.path)
      if path
        ext = File.extname(path)[1..-1]
        handler = Serve::FileTypeHandler.handlers[ext]
        if handler
          handler.new(@root, path).process(request, response)
          response
        else
          default(request, response)
        end
      else
        default(request, response)
      end
    end
    
    def default(request, response)
      response.status = 404
      response.body = "Not found!"
      response
    end
    
  end
end
