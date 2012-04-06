module Serve #:nodoc:
  class RedirectHandler < FileTypeHandler  #:nodoc:
    extension 'redirect'
    
    def process(input, context)
      lines = input.strip.split("\n")
      url = lines.last.strip
      unless url =~ %r{^\w[\w+.-]*:.*}
        url = context.request.protocol + context.request.host_with_port + url
      end
      context.response.redirect(url, '302')
    end

    def layout?
      false
    end
  end
end