module Serve #:nodoc:
  # The Sass handler seems to be necessar to keep Tilt from applying a layout
  # to Sass files. Any one know how to turn this off?
  class SassHandler < FileTypeHandler #:nodoc:
    extension 'sass', 'scss'
    
    def parse(string)
      require 'sass'
      engine = Sass::Engine.new(string,
        :load_paths => [@root_path],
        :style => :expanded,
        :filename => @script_filename,
        :syntax => syntax(@script_filename)
      )
      engine.render
    end
    
    def syntax(filename)
      ext = File.extname(@script_filename)
      if ext == '.scss'
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