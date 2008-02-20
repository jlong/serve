begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'serve'