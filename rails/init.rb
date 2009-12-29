require 'serve/rails'

ActionController::Routing::RouteSet::Mapper.send :include, Serve::Rails::Routing::MapperExtensions
ActionController::AbstractResponse.module_eval do
  attr_accessor :cache_timeout
end