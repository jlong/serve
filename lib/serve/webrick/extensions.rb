# Portions from Rails, Copyright (c) 2004-2008 David Heinemeier Hansson
require 'active_support/memoizable'

module Serve #:nodoc:
  module WEBrick #:nodoc:
    
    module FileHandlerExtensions #:nodoc:
      def self.included(base)
        base.extend(self)
        base.class_eval do
          alias :search_file_without_auto_appending :search_file
          alias :search_file :search_file_with_auto_appending
        end
      end
      
      def search_file_with_auto_appending(req, res, basename)
        full_path = File.join(res.filename, basename)
        return basename if File.file?(full_path)
        return nil if File.directory?(full_path)
        Serve.resolve_file(Dir.pwd, req.path)
      end
    end
    
  end
end

WEBrick::HTTPRequest.module_eval do
  extend ActiveSupport::Memoizable

  alias headers header

  # Returns the \host for this request, such as "example.com".
  def raw_host_with_port
    @host + ':' + @port.to_s
  end

  # Returns 'https://' if this is an SSL request and 'http://' otherwise.
  def protocol
    ssl? ? 'https://' : 'http://'
  end
  memoize :protocol

  # Is this an SSL request?
  def ssl?
    meta_vars['HTTPS'] == 'on'
  end

  def params
    query.inject({}) {|m, (k,v)| m[k.to_s.to_sym] = v; m}
  end

  # Returns the host for this request, such as example.com.
  def host
    raw_host_with_port.sub(/:\d+$/, '')
  end
  memoize :host

  # Returns a \host:\port string for this request, such as "example.com" or
  # "example.com:8080".
  def host_with_port
    "#{host}#{port_string}"
  end
  memoize :host_with_port

  # Returns the port number of this request as an integer.
  def port
    if raw_host_with_port =~ /:(\d+)$/
      $1.to_i
    else
      standard_port
    end
  end
  memoize :port

  # Returns the standard \port number for this request's protocol.
  def standard_port
    case protocol
      when 'https://' then 443
      else 80
    end
  end

  # Returns a \port suffix like ":8080" if the \port number of this request
  # is not the default HTTP \port 80 or HTTPS \port 443.
  def port_string
    port == standard_port ? '' : ":#{port}"
  end
end

WEBrick::HTTPResponse.module_eval do
  alias headers header
  
  def redirect(url, status)
    set_redirect(::WEBrick::HTTPStatus[status.to_i], url)
  end
end

WEBrick::HTTPServlet::FileHandler.class_eval { include Serve::WEBrick::FileHandlerExtensions }