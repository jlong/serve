module Serve #:nodoc:  
  class CoffeeHandler < FileTypeHandler #:nodoc:
    extension 'coffee'
    
    def parse(string)
      engine = Tilt::CoffeeScriptTemplate.new { string }
      engine.render
    end
    
    def content_type
      'text/javascript'
    end
  end
end