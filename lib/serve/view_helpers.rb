module Serve #:nodoc:
  # Many of the methods here have been extracted in some form from Rails
  
  module EscapeHelpers
    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }
    JSON_ESCAPE = { '&' => '\u0026', '>' => '\u003E', '<' => '\u003C' }
    
    # A utility method for escaping HTML tag characters.
    # This method is also aliased as <tt>h</tt>.
    #
    # In your ERb templates, use this method to escape any unsafe content. For example:
    #   <%=h @person.name %>
    #
    # ==== Example:
    #   puts html_escape("is a > 0 & a < 10?")
    #   # => is a &gt; 0 &amp; a &lt; 10?
    def html_escape(s)
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end
    alias h html_escape
    
    # A utility method for escaping HTML entities in JSON strings.
    # This method is also aliased as <tt>j</tt>.
    #
    # In your ERb templates, use this method to escape any HTML entities:
    #   <%=j @person.to_json %>
    #
    # ==== Example:
    #   puts json_escape("is a > 0 & a < 10?")
    #   # => is a \u003E 0 \u0026 a \u003C 10?
    def json_escape(s)
      s.to_s.gsub(/[&"><]/) { |special| JSON_ESCAPE[special] }
    end
    alias j json_escape
  end
  
  module ContentHelpers
    def content_for(symbol, &block)
      set_content_for(symbol, capture(&block))
    end
    
    def content_for?(symbol)
      !(get_content_for(symbol)).nil?
    end
    
    def get_content_for(symbol = :content)
      if symbol.to_s.intern == :content
        @content
      else
        instance_variable_get("@content_for_#{symbol}")
      end
    end
    
    def set_content_for(symbol, value)
      instance_variable_set("@content_for_#{symbol}", value)
    end
    
    def capture_erb(&block)
      buffer = ""
      old_buffer, @_out_buf = @_out_buf, buffer
      yield
      buffer
    ensure
      @_out_buf = old_buffer
    end
    alias capture_rhtml capture_erb
    alias capture_erubis capture_erb
    
    def capture(&block)
      capture_method = "capture_#{script_extension}"
      if respond_to? capture_method
        send capture_method, &block
      else
        raise "Capture not supported for `#{script_extension}' template (#{engine_name})"
      end
    end
    
    private
      
      def engine_name
        Tilt[script_extension].to_s
      end
      
      def script_extension
        parser.script_extension
      end
  end
  
  module FlashHelpers
    def flash
      @flash ||= {}
    end
  end
  
  module ParamHelpers
    
    # Key based access to query parameters. Keys can be strings or symbols.
    def params
      @params ||= request.params
    end
    
    # Extract the value for a bool param. Handy for rendering templates in
    # different states.
    def boolean_param(key, default = false)
      key = key.to_s.intern
      value = params[key]
      return default if value.blank?
      case value.strip.downcase
        when 'true', '1'  then true
        when 'false', '0' then false
        else raise 'Invalid value'
      end
    end
  end
  
  module RenderHelpers
    def render(partial, options={})
      if partial.is_a?(Hash)
        options = options.merge(partial)
        partial = options.delete(:partial)
      end  
      template = options.delete(:template)
      case
      when partial
        render_partial(partial, options)
      when template
        render_template(template)
      else
        raise "render options not supported #{options.inspect}"
      end
    end
    
    def render_partial(partial, options={})
      render_template(partial, options.merge(:partial => true))
    end
    
    def render_template(template, options={})
      path = File.dirname(parser.script_filename)
      if template =~ %r{^/}
        template = template[1..-1]
        path = @root_path
      end
      filename = template_filename(File.join(path, template), :partial => options[:partial])
      if File.file?(filename)
        parser.parse_file(filename, options[:locals])
      else
        raise "File does not exist #{filename.inspect}"
      end
    end
    
    private
      
      def template_filename(name, options)
        path = File.dirname(name)
        template = File.basename(name)
        template = "_" + template if options[:partial]
        template += extname(parser.script_filename) unless name =~ /\.[a-z]+$/
        File.join(path, template)
      end
      
      def extname(filename)
        /(\.[a-z]+\.[a-z]+)$/.match(filename)
        $1 || File.extname(filename) || ''
      end
      
  end
  
  module TagHelpers
    def content_tag(name, content, html_options={})
      %{<#{name}#{html_attributes(html_options)}>#{content}</#{name}>}
    end
    
    def tag(name, html_options={})
      %{<#{name}#{html_attributes(html_options)} />}
    end
    
    def image_tag(src, html_options = {})
      tag(:img, html_options.merge({:src=>src}))
    end
    
    def image(name, options = {})
      image_tag(ensure_path(ensure_extension(name, 'png'), 'images'), options)
    end
    
    def javascript_tag(content = nil, html_options = {})
      content_tag(:script, javascript_cdata_section(content), html_options.merge(:type => "text/javascript"))
    end
    
    def link_to(name, href, html_options = {})
      html_options = html_options.stringify_keys
      confirm = html_options.delete("confirm")
      onclick = "if (!confirm('#{html_escape(confirm)}')) return false;" if confirm
      content_tag(:a, name, html_options.merge(:href => href, :onclick=>onclick))
    end
    
    def link_to_function(name, *args, &block)
      html_options = extract_options!(args)
      function = args[0] || ''
      onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
      href = html_options[:href] || '#'
      content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
    end
    
    def mail_to(email_address, name = nil, html_options = {})
      html_options = html_options.stringify_keys
      encode = html_options.delete("encode").to_s
      cc, bcc, subject, body = html_options.delete("cc"), html_options.delete("bcc"), html_options.delete("subject"), html_options.delete("body")
      
      string = ''
      extras = ''
      extras << "cc=#{CGI.escape(cc).gsub("+", "%20")}&" unless cc.nil?
      extras << "bcc=#{CGI.escape(bcc).gsub("+", "%20")}&" unless bcc.nil?
      extras << "body=#{CGI.escape(body).gsub("+", "%20")}&" unless body.nil?
      extras << "subject=#{CGI.escape(subject).gsub("+", "%20")}&" unless subject.nil?
      extras = "?" << extras.gsub!(/&?$/,"") unless extras.empty?
      
      email_address = email_address.to_s
      
      email_address_obfuscated = email_address.dup
      email_address_obfuscated.gsub!(/@/, html_options.delete("replace_at")) if html_options.has_key?("replace_at")
      email_address_obfuscated.gsub!(/\./, html_options.delete("replace_dot")) if html_options.has_key?("replace_dot")
      
      if encode == "javascript"
        "document.write('#{content_tag("a", name || email_address_obfuscated, html_options.merge({ "href" => "mailto:"+email_address+extras }))}');".each_byte do |c|
          string << sprintf("%%%x", c)
        end
        "<script type=\"#{Mime::JS}\">eval(decodeURIComponent('#{string}'))</script>"
      elsif encode == "hex"
        email_address_encoded = ''
        email_address_obfuscated.each_byte do |c|
          email_address_encoded << sprintf("&#%d;", c)
        end
        
        protocol = 'mailto:'
        protocol.each_byte { |c| string << sprintf("&#%d;", c) }
        
        email_address.each_byte do |c|
          char = c.chr
          string << (char =~ /\w/ ? sprintf("%%%x", c) : char)
        end
        content_tag "a", name || email_address_encoded, html_options.merge({ "href" => "#{string}#{extras}" })
      else
        content_tag "a", name || email_address_obfuscated, html_options.merge({ "href" => "mailto:#{email_address}#{extras}" })
      end
    end

    # Generates JavaScript script tags for the sources given as arguments.
    #
    # If the .js extension is not given, it will be appended to the source.
    #
    # Examples
    #     javascript_include_tag 'application' # =>
    #       <script src="/javascripts/application.js" type="text/javascript" />
    #
    #     javascript_include_tag 'https://cdn/jquery.js' # =>
    #       <script src="https://cdn/jquery.js" type="text/javascript" />
    #
    #     javascript_include_tag 'application', 'books' # =>
    #       <script src="/javascripts/application.js" type="text/javascript" />
    #       <script src="/javascripts/books.js" type="text/javascript" />
    #
    def javascript_include_tag(*sources)
      options = extract_options!(sources)

      sources.map do |source|
        content_tag('script', '', {
          'type' => 'text/javascript',
          'src' => ensure_path(ensure_extension(source, 'js'), 'javascripts')
        }.merge(options))
      end.join("\n")
    end

    # Generates stylesheet link tags for the sources given as arguments.
    #
    # If the .css extension is not given, it will be appended to the source.
    #
    # Examples
    #     stylesheet_link_tag 'screen' # =>
    #       <link href="/stylesheets/screen.css" media="screen" rel="stylesheet" type="text/css" />
    #
    #     stylesheet_link_tag 'print', :media => 'print' # =>
    #       <link href="/stylesheets/print.css" media="print" rel="stylesheet" type="text/css" />
    #
    #     stylesheet_link_tag 'application', 'books', 'authors' # =>
    #       <link href="/stylesheets/application.css" media="screen" rel="stylesheet" type="text/css" />
    #       <link href="/stylesheets/books.css" media="screen" rel="stylesheet" type="text/css" />
    #       <link href="/stylesheets/authors.css" media="screen" rel="stylesheet" type="text/css" />
    #
    def stylesheet_link_tag(*sources)
      options = extract_options!(sources)

      sources.map do |source|
        tag('link', {
          'rel' => 'stylesheet',
          'type' => 'text/css',
          'media' => 'screen',
          'href' => ensure_path(ensure_extension(source, 'css'), 'stylesheets')
        }.merge(options))
      end.join("\n")
    end
    
    private
      
      def cdata_section(content)
        "<![CDATA[#{content}]]>"
      end
      
      def javascript_cdata_section(content) #:nodoc:
        "\n//#{cdata_section("\n#{content}\n//")}\n"
      end
      
      def html_attributes(options)
        unless options.blank?
          attrs = []
          options.each_pair do |key, value|
            if value == true
              attrs << %(#{key}="#{key}") if value
            else
              attrs << %(#{key}="#{value}") unless value.nil?
            end
          end
          " #{attrs.sort * ' '}" unless attrs.empty?
        end
      end

      # Ensures a proper extension is appended to the filename.
      #
      # If a URI with the http or https scheme name is given, it is assumed
      # to be absolute and will not be altered.
      #
      # Examples
      #     ensure_extension('screen', 'css') => 'screen.css'
      #     ensure_extension('screen.css', 'css') => 'screen.css'
      #     ensure_extension('jquery.min', 'js') => 'jquery.min.js'
      #     ensure_extension('https://cdn/jquery', 'js') => 'https://cdn/jquery'
      #
      def ensure_extension(source, extension)
        if source =~ /^https?:/ || source.end_with?(".#{extension}")
          return source
        end

        "#{source}.#{extension}"
      end

      # Ensures the proper path to the given source.
      #
      # If the source begins at the root of the public directory or is a URI
      # with the http or https scheme name, it is assumed to be absolute and
      # will not be altered.
      #
      # Examples
      #     ensure_path('screen.css', 'stylesheets') => '/stylesheets/screen.css'
      #     ensure_path('/screen.css', 'stylesheets') => '/screen.css'
      #     ensure_path('http://cdn/jquery.js', 'javascripts') => 'http://cdn/jquery.js'
      #
      def ensure_path(source, path)
        if source =~ /^(\/|https?)/
          return source
        end

        File.join('', path, source)
      end

      # Returns a hash of options if they exist at the end of an array.
      #
      # This is useful when working with splats.
      #
      # Examples
      #     extract_options!([1, 2, { :name => 'sunny' }]) => { :name => 'sunny' }
      #     extract_options!([1, 2, 3]) => {}
      #
      def extract_options!(array)
        array.last.instance_of?(Hash) ? array.pop : {}
      end
  end
  
  module ViewHelpers #:nodoc:
    include EscapeHelpers
    include ContentHelpers
    include FlashHelpers
    include ParamHelpers
    include RenderHelpers
    include TagHelpers
  end
end
