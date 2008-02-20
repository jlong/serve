module Serve #:nodoc:
  class MarkdownHandler < FileTypeHandler #:nodoc:
    extension 'markdown'
  
    def parse(string)
      require 'bluecloth'
      "<html><body>#{ BlueCloth.new(string).to_html }</body></html>"
    end
  end
end