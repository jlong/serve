module Serve #:nodoc:
  class RedirectHandler < FileTypeHandler  #:nodoc:
    extension 'redirect'
    
    def process(req, res)
      data = super
      res['location'] = data.strip
      res.body = ''
      raise ::WEBrick::HTTPStatus::Found
    end
  end
end