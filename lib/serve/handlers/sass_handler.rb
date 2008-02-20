module Serve #:nodoc:
  class SassHandler < FileTypeHandler #:nodoc:
    extension 'sass'
  
    def parse(string)
      require 'sass'
      engine = Sass::Engine.new(string,
        :style => :expanded,
        :filename => @script_filename
      )
      engine.render 
    end
  
    def content_type
      'text/css'
    end
  end
end