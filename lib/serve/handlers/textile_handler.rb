module Serve #:nodoc:
  # TODO: Is the Textile handler needed now that we are using Tilt?
  class TextileHandler < FileTypeHandler #:nodoc:
    extension 'textile'
    
    def parse(string)
      require 'redcloth'
      "<html><body>#{ RedCloth.new(string).to_html }</body></html>"
    end
  end
end