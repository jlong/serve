require 'active_support'
require 'rack'

module Serve
  class Request < Rack::Request
    def query
      @query ||= Rack::Utils.parse_nested_query(query_string)
    end
    
    def protocol
      @scheme ||= scheme + "://"
    end
    
    def headers
      @headers ||= Headers.new(@env)
    end
  end
  
  class Response < Rack::Response
    def body=(value)
      # needed for Ruby 1.9
      if value.respond_to? :each
        super(value)
      else
        super([value])
      end
    end
  end
  
  # Borrowed from ActionDispatch in Rails
  class Headers < Hash
    extend ActiveSupport::Memoizable
    
    def initialize(*args)
      if args.size == 1 && args[0].is_a?(Hash)
        super()
        update(args[0])
      else
        super
      end
    end
    
    def [](header_name)
      if include?(header_name)
        super
      else
        super(env_name(header_name))
      end
    end
    
    private
      # Converts a HTTP header name to an environment variable name.
      def env_name(header_name)
        "HTTP_#{header_name.upcase.gsub(/-/, '_')}"
      end
      memoize :env_name
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
