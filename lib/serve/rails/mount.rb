module Serve
  module Rails
    class Mount # :nodoc:
      attr_reader :root_path, :route
      
      def initialize(route, root)
        @route, @root_path = route, root
        @view_helper_module_names = []
      end
      
      # Appends to the collection of view helpers that will be made availabe
      # to the DynamicHandler. These should be module names. They will be
      # constantized in order to allow for re-loading in development mode.
      #
      def append_view_helper(module_name)
        @view_helper_module_names << module_name
      end
      
      def connection
        @route == '/' ? '*path' : "#{@route}/*path"
      end
      
      def resolve_path(path)
        Serve.resolve_filename(@root_path, path)
      end
      
      def view_helpers
        helpers = Module.new
        @view_helper_module_names.each do |module_name|
          helpers.module_eval do
            include module_name.constantize
          end
        end
        helpers
      end
    end
  end
end