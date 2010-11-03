require 'fileutils'
require 'open-uri'

module Serve
  module JavaScripts
    
    # JavaScript Versions
    GOOGLE_AJAX_APIS      = 'http://ajax.googleapis.com/ajax/libs'
    JQUERY_VERSION        = '1' # the latest stable version of 1.x.x
    JQUERY_UI_VERSION     = '1'
    PROTOTYPE_VERSION     = '1'
    SCRIPTACULOUS_VERSION = '1'
    MOOTOOLS_VERSION      = '1'
    
    JAVASCRIPT_FRAMEWORKS = %w(jquery jquery-ui mootools prototype scriptaculous)
    
    def fetch_javascript(framework, download_path)
      filename = javascript_filename(framework, download_path)
      framework_url = javascript_framework_url(framework)
      lines = open(framework_url) { |io| io.read }
      open(filename, "w+") { |io| io.write(lines) }
    end
    
    def supported_javascript_frameworks
      JAVASCRIPT_FRAMEWORKS
    end
    
    def valid_javascript_framework?(framework)
      framework = framework.downcase
      JAVASCRIPT_FRAMEWORKS.include?(framework)
    end
    
    def javascript_filename(framework, path)
      File.join(path, "#{framework}.js")
    end
    
    def javascript_framework_url(framework)
      self.send(framework.tr('-', '_') + "_url")
    end
    
    def jquery_url
      "#{GOOGLE_AJAX_APIS}/jquery/#{JQUERY_VERSION}/jquery.min.js"
    end
    
    def jquery_ui_url
      "#{GOOGLE_AJAX_APIS}/jqueryui/#{JQUERY_UI_VERSION}/jquery-ui.min.js"
    end
    
    def mootools_url
      "#{GOOGLE_AJAX_APIS}/mootools/#{MOOTOOLS_VERSION}/mootools-yui-compressed.js"
    end
    
    def prototype_url
      "#{GOOGLE_AJAX_APIS}/prototype/#{PROTOTYPE_VERSION}/prototype.js"
    end
    
    def scriptaculous_url
      "#{GOOGLE_AJAX_APIS}/scriptaculous/#{SCRIPTACULOUS_VERSION}/scriptaculous.js"
    end
     
  end
end