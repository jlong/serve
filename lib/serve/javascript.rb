module Serve
  class JavaScript
    class << self
      
      ##
      # Install
      #
      # @param  [Symbol/String]
      # @param  [File]
      #
      def install(framework, location)
        case framework.to_sym
        when :jquery      then get(install_location(location, 'jquery'), jquery)
        when :jqueryui    then get(install_location(location, 'jquery-ui'), jqueryui)
        when :mootools    then get(install_location(location, 'mootools'), mootools)
        when :prototype   then get(install_location(location, 'prototype'), prototype)
        when :scripty     then get(install_location(location, 'scriptaculous'), scripty)
        else
          return false
        end
      end
      
      private
        
        def get(library_path, local_path)
          system("curl -o #{library_path} #{local_path}")
        end
        
        def install_location(location, framework)
          File.join(location, "public/javascripts/#{framework}.js")
        end
        
        def jquery
          'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js'
        end
        
        def jqueryui
          'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.5/jquery-ui.min.js'
        end
        
        def mootools
          'http://ajax.googleapis.com/ajax/libs/mootools/1.2.5/mootools-yui-compressed.js'
        end
        
        def prototype
          'http://ajax.googleapis.com/ajax/libs/prototype/1.6.1.0/prototype.js'
        end
        
        def scripty
          'http://ajax.googleapis.com/ajax/libs/scriptaculous/1.8.3/scriptaculous.js'
        end
        
    end
  end
end