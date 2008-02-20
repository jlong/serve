module Serve #:nodoc:
  class EmailHandler < FileTypeHandler #:nodoc:
    extension 'email'
    
    def parse(string)
      title = "E-mail"
      title = $1 + " #{title}" if string =~ /^Subject:\s*(\S.*?)$/im
      head, body = string.split("\n\n", 2)
      output = []
      output << "<html><head><title>#{title}</title></head>"
      output << '<body style="font-family: Arial; line-height: 1.2em; font-size: 90%; margin: 0; padding: 0">'
      output << '<div id="head" style="background-color: #E9F2FA; padding: 1em">'
      head.each do |line|
        key, value = line.split(":", 2).map { |a| a.strip }
        output << "<div><strong>#{key}:</strong> #{value}</div>"
      end
      output << '</div><pre id="body" style="font-size: 110%; padding: 1em">'
      output << body
      output << '</pre></body></html>'
      output.join("\n")
    end
  end
end