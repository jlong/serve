require 'webrick'

module Serve #:nodoc:
  module FileHandlerExtensions
    
    def self.included(base)
      base.extend(self)
      base.class_eval do
        alias :search_file_without_auto_appending :search_file
        alias :search_file :search_file_with_auto_appending
      end
    end
    
    def search_file_with_auto_appending(req, res, basename)
      if result = search_file_without_auto_appending(req, res, basename)
        return result
      end
      extensions = @config[:AppendExtensions]
      basename = $1 if basename =~ %r{^(.*?)/$}
      if extensions
        extensions.each do |ext|
          if result = search_file_without_auto_appending(req, res, "#{basename}.#{ext}")
            return result
          end
        end
      end
      return nil
    end
    
  end
end

WEBrick::HTTPServlet::FileHandler.class_eval { include Serve::FileHandlerExtensions }