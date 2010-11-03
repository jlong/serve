require 'fileutils'
require 'open-uri'

module Serve
  class JavaScript

    attr_reader :directory

    # JavaScript Versions
    GOOGLE_AJAX_APIS      = 'http://ajax.googleapis.com/ajax/libs'
    JQUERY_VERSION        = '1.4.2'
    JQUERY_UI_VERSION     = '1.8.5'
    PROTOTYPE_VERSION     = '1.6.1.0'
    SCRIPTACULOUS_VERSION = '1.8.3'
    MOOTOOLS              = '1.2.5'
    
    FRAMEWORKS            = %w(jQuery jQueryUI MooTools Prototype Scriptaculous)
    
    
    # Initialize
    #
    # e.g.
    #   Serve::JavaScript.new(Dir.pwd).install('jquery')
    #
    def initialize(directory)
      @directory = directory
      FileUtils.mkdir_p(install_directory) unless File.exists?(install_directory)
    end
    
    
    
    # Install
    #
    # @param  [String]
    #
    def install(framework)
      case framework.to_s
      when 'jquery'         then get('jquery')
      when 'jqueryui'       then get('jquery_ui')
      when 'jquery_ui'      then get('jquery_ui')
      when 'mootools'       then get('mootools')
      when 'prototype'      then get('prototype')
      when 'scriptaculous'  then get('scriptaculous')
      else
        puts "** #{framework} is not currently supported. **"
        puts "Currently supporting the following JavaScript Frameworks:"
        puts "#{FRAMEWORKS.join(', ')}"
      end
    end
    
    
    private
      
      def get(framework)
        library_path = File.join(install_directory, "#{framework.tr('_', '-')}.js")
        lines = open(self.send(framework + "_url")) { |io| io.read }
        open(library_path, "w+") { |io| io.write(lines) }
      end
      
      def install_directory
        File.join(@directory, 'public/javascripts')
      end
      
      def jquery_url
        "#{GOOGLE_AJAX_APIS}/jquery/#{JQUERY_VERSION}/jquery.min.js"
      end
      
      def jquery_ui_url
        "#{GOOGLE_AJAX_APIS}/jqueryui/#{JQUERY_UI_VERSION}/jquery-ui.min.js"
      end
      
      def mootools_url
        "#{GOOGLE_AJAX_APIS}/mootools/#{MOOTOOLS}/mootools-yui-compressed.js"
      end
      
      def prototype_url
        "#{GOOGLE_AJAX_APIS}/prototype/#{PROTOTYPE_VERSION}/prototype.js"
      end
      
      def scriptaculous_url
        "#{GOOGLE_AJAX_APIS}/scriptaculous/#{SCRIPTACULOUS_VERSION}/scriptaculous.js"
      end
        
  end
end