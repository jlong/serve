require 'webrick'
require 'serve/version'
require 'serve/webrick/extensions'
require 'serve/handlers/file_type_handler'
require 'serve/handlers/textile_handler'
require 'serve/handlers/markdown_handler'
require 'serve/handlers/haml_handler'
require 'serve/handlers/sass_handler'
require 'serve/handlers/email_handler'
require 'serve/handlers/redirect_handler'

module Serve #:nodoc:
  class Server < ::WEBrick::HTTPServer #:nodoc:
  end
end