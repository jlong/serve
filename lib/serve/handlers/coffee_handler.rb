module Serve #:nodoc:
  
  # TODO: Figure out how to remove the Sass Handler in favor of Tilt
  # The Sass handler seems to be necessary to keep Tilt from applying a layout
  # to Sass files. Any one know how to turn this Tilt feature off?
  
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