module Serve #:nodoc:
  
  # TODO: Figure out how to remove the Sass Handler in favor of Tilt
  # The Sass handler seems to be necessary to keep Tilt from applying a layout
  # to Sass files. Any one know how to turn this Tilt feature off?
  
  class SassHandler < FileTypeHandler #:nodoc:
    extension 'sass', 'scss'
    
    def parse(string, context)
      require 'sass'
      engine = Sass::Engine.new(string,
        :load_paths => [@root_path] + Sass::Engine::DEFAULT_OPTIONS[:load_paths],
        :style => :expanded,
        :syntax => syntax
      )
      engine.render
    end
    
    def syntax
      if extension == 'scss'
        :scss
      else
        :sass
      end
    end
    
    def content_type
      'text/css'
    end
  end
end
