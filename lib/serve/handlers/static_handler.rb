module Serve #:nodoc:
  class StaticHandler < FileTypeHandler #:nodoc:
    extension 'txt', 'text', 'xml', 'atom', 'rss', 'rdf', 'htm', 'html'
    
    def content_type
      case File.extname(@script_filename)
        when '.txt', '.text'
          'text/plain'
        when '.xml'
          'text/xml'
        when '.atom'
          'application/atom+xml'
        when '.rss'
          'application/rss+xml'
        when '.rdf'
          'application/rdf+xml'
        else
          'text/html'
      end
    end
  end
end