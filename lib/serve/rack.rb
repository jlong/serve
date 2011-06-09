require 'active_support/all'
require 'rack'

module Serve
  class Request < Rack::Request
    # Returns a Hash of the query params for a request's URL.
    def get_params
      @get_params ||= Rack::Utils.parse_nested_query(query_string)
    end
    alias query get_params
    
    # Returns a Hash of the query params for a posted form
    def post_params
      @post_params ||= form_data? ? Rack::Utils.parse_nested_query(body.read) : {}
    end
    
    # Key based access to query parameters. Keys can be strings or symbols.
    def params
      @params ||= begin
        hash = HashWithIndifferentAccess.new.update(get_params)
        hash.update(post_params) if form_data?
        hash
      end
    end
    
    # Returns the protocol part of the URL for a request: "http://", "https://", etc.
    def protocol
      @scheme ||= scheme + "://"
    end
    
    # Returns a specialized hash of the headers on the request.
    def headers
      @headers ||= Headers.new(@env)
    end
    
    # Returns the value of the "REQUEST_URI" environment variable.
    def request_uri
      @env["REQUEST_URI"].to_s
    end
    
    # Set the value of the "REQUEST_URI" environment variable.
    def request_uri=(s)
      @env["REQUEST_URI"] = s.to_s
    end
  end
  
  class Response < Rack::Response
    
    # Set the body of a response.
    def body=(value)
      # needed for Ruby 1.9
      if value.respond_to? :each
        super(value)
      else
        super([value])
      end
    end
    
  end
  
  # A specialized hash for the environment variables on a request.
  # Borrowed from ActionDispatch in Rails.
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
    
    # Initialize a Rack endpoint for Serve with the root path to
    # the views directory.
    def initialize(root)
      @root = root
    end
    
    # Called by Rack to process a request.
    def call(env)
      request = Request.new(env)
      response = Response.new()
      process(request, response).to_a
    end
    
    protected
      
      # Process the request and response. Paths are transformed so that
      # URLs without extensions and directory indexes work.
      def process(request, response)
        path = Serve::Router.resolve(@root, request.path_info)
        if path
          # Fetch the file handler for a file with a given extension/
          ext = File.extname(path)[1..-1]
          handler = Serve::FileTypeHandler.handlers[ext]
          if handler
            # Handler exists? Process the request and response.
            handler.new(@root, path).process(request, response)
            response
          else
            # Handler doesn't exist? Rewrite the request to use the new path.
            # This allows Rack::Cascade or Passenger to deliver a file that is
            # not handled by one of the Serve handlers.
            rewrite(request, response, path)
          end
        else
          # Return a 404 response.
          not_found(request, response)
        end
      end
      
      # Returns a 404 response.
      def not_found(request, response)
        response.status = 404
        response.body = "Not found!"
        response
      end
      
      # Rewrite the request to use a new path. Return a 404 response so that Rack::Cascade works.
      def rewrite(request, response, path)
        request.request_uri = path + request.query_string
        request.path_info = path
        not_found(request, response)
      end
    
  end
end
