$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'serve'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end