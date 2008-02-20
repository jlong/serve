module Serve #:nodoc:
  class TextileHandler < FileTypeHandler #:nodoc:
    extension 'textile'
  
    def parse(string)
      require 'redcloth'
      "<html><body>#{ RedCloth.new(string).to_html }</body></html>"
    end
  end
end