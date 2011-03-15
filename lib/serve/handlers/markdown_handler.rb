module Serve #:nodoc:
  # TODO: Is the Markdown handler needed now that we are using Tilt?
  class MarkdownHandler < FileTypeHandler #:nodoc:
    extension 'markdown'
    
    def parse(string)
      require 'bluecloth'
      "<html><body>#{ BlueCloth.new(string).to_html }</body></html>"
    end
  end
end