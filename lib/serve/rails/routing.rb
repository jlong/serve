module Serve
  module Rails
    module Routing
      
      module MapperExtensions
        def serve
          serve_mounts = Serve::Rails.configuration.mounts
          default_site_path = File.join(::Rails.root, 'site')
          
          if File.directory?(default_site_path) && !serve_mounts.detect {|m| m.route == '/'}
            mount('/', default_site_path)
          end
          
          serve_mounts.each do |mount|
            @set.add_route(mount.connection, {
              :controller => 'serve', :action => 'show',
              :serve_route => mount.route
            })
          end
        end
      end
      
    end
  end
end