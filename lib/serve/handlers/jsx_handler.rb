module Serve #:nodoc:
  class JsxHandler < FileTypeHandler #:nodoc:
    extension 'jsx'
    
    def parse(string, context)
      require 'react/jsx'
      React::JSX.compile(string)
    end
    
    def content_type
      'text/javascript'
    end
  end
end
