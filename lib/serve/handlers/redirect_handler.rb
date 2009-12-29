module Serve #:nodoc:
  class RedirectHandler < FileTypeHandler  #:nodoc:
    extension 'redirect'
    
    def process(request, response)
      url = super.strip
      unless url =~ %r{^\w[\w\d+.-]*:.*}
        url = request.protocol + request.host_with_port + url
      end
      response.redirect(url, '302')
    end
  end
end