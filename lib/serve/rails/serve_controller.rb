module Serve
  module Rails
    
    module ServeController
      def show
        response.headers.delete('Cache-Control')
        cache = Serve::Rails.cache(request)
        if cache.response_cached?(request.path)
          cache.update_response(request.path, response, request)
        else
          mount = Serve::Rails.configuration.mounts.detect {|m| m.route == params[:serve_route]}
          if path = mount.resolve_path(params[:path] || '/')
            handler_class = Serve::FileTypeHandler.find(path)
            handler = handler_class.new(mount.root_path, path)
            install_view_helpers(handler, mount.view_helpers) if handler_class == Serve::DynamicHandler
            handler.process(request, response)
            cache.cache_response(request.path, response)
          else
            render_not_found
          end
        end
        @performed_render = true
      end
      
      private
        def render_not_found
          render :text => 'not found', :status => 404
        end
        
        # This is a quick solution: We need to install the view helpers defined by
        # the Rails application after those of the Serve'd app's view helpers, so
        # that those of the Rails application override them.
        #
        # Ideally, we'll work toward moving some of this Rails stuff further up
        # into Serve, so that a simple Serve'd directory uses almost all of the
        # same code, like the Configuration.
        #
        def install_view_helpers(handler, view_helpers)
          controller = self
          handler.singleton_class.module_eval do
            define_method :install_view_helpers do |context|
              super(context)
              # Make available to view helpers
              context.instance_variable_set('@controller', controller)
              context.extend view_helpers
            end
          end
        end
    end
    
  end
end