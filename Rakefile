require 'config/requirements'
require 'config/hoe' # setup Hoe + all gem configuration

Dir['tasks/**/*.rake'].each { |rake| load rake }

undefine_task %w(
  default
  test
  test_deps
  config_hoe
)

task :default => :spec