require 'active_support/all'

module Kernel
  # Returns the object's singleton class.
  def singleton_class
    metaclass
  end if !respond_to?(:singleton_class) && respond_to?(:metaclass) # exists in active_support 3.x but not 2.3.5
end

require 'serve/version'
require 'serve/router'
require 'serve/handlers/file_type_handler'
require 'serve/handlers/dynamic_handler'
require 'serve/handlers/sass_handler'
require 'serve/handlers/less_handler'
require 'serve/handlers/email_handler'
require 'serve/handlers/redirect_handler'
require 'serve/rack'