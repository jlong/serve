module Serve #:nodoc:
  
  # TODO: Figure out how to remove the Less Handler in favor of Tilt
  # The Less handler seems to be necessary to keep Tilt from applying a layout
  # to Less files. Any one know how to turn this Tilt feature off?
  
  class LessHandler < FileTypeHandler #:nodoc:
    extension 'less'
    
    def parse(string)
      require 'less'
      Less.parse(string)
    end
    
    def content_type
      'text/css'
    end
  end
end