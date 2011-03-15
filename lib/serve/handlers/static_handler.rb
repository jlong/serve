module Serve #:nodoc:
  
  # TODO: Figure out a way to remove the need for this handler. Right now
  # Serve requires this in order to deliver these files with the right content
  # type headers.
  
  class StaticHandler < FileTypeHandler #:nodoc:
    extension 'txt', 'text', 'xml', 'atom', 'rss', 'rdf', 'css', 'htm', 'html'
    
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
        when '.htc'
          'text/x-component'
        when 'css'
          'text/css'
        else
          'text/html'
      end
    end
  end
end