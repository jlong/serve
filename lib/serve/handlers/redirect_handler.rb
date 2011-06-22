module Serve #:nodoc:
  class RedirectHandler < FileTypeHandler  #:nodoc:
    extension 'redirect'
    
    def process(request, response)
      lines = super.strip.split("\n")
      url = lines.last.strip
      unless url =~ %r{^\w[\w\d+.-]*:.*}
        url = request.protocol + request.host_with_port + url
      end
      response.redirect(url, '302')
    end
  end
end