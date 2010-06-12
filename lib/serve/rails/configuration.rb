module Serve # :nodoc:
  module Rails
    class Configuration # :nodoc:
      attr_reader :mounts, :view_helpers
      
      def initialize
        Serve::ResponseCache.defaults.update(
          :logger => ActionController::Base.logger,
          :perform_caching => ActionController::Base.perform_caching
        )
        
        @mounts = []
        
        define_find_cache do |request|
          @default_cache ||= Serve::ResponseCache.new(
            :directory => File.join(::Rails.root, 'tmp', 'serve_cache')
          )
        end
      end
      
      def define_find_cache(&block)
        singleton_class.module_eval do
          define_method :find_cache, &block
        end
      end
      
      def mount(route, root_path)
        m = Mount.new(route, root_path)
        @mounts << m
        yield m if block_given?
        m
      end
    end
    
    # Answer the cache for the given request. Delegates to the 'find_cache'
    # block, which defaults to a single cache.
    #
    def self.cache(request)
      configuration.find_cache(request)
    end
    
    def self.configuration
      @configuration ||= Configuration.new
    end
    
    # The most powerful way to configure Serve::Rails, the configuration is
    # yielded to the provided block. Multiple calls are cumulative - there is
    # only one configuration instance.
    #
    def self.configure
      yield configuration
    end
    
    # Define the strategy for resolving the cache for a request. This allows
    # applications to provide logic like cache-per-browser. The default is a
    # single cache.
    #
    def self.find_cache(&block)
      configuration.define_find_cache(&block)
    end
    
    # Mount a route on a directory. This allows an application to have
    # multiple served directories, each connected to different routes.
    #
    def self.mount(route, root_path, &block)
      configuration.mount(route, root_path, &block)
    end
  end
end