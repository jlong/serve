#
# Serve::Project.new('mockup', '.').create
# Serve::Project.new('mockup', '.').convert
#
#
module Serve
  class Project
    attr_reader :name, :location, :framework
    
    
    def initialize(name, location, framework=nil)
      @name       = name
      @location   = location ? File.join(File.expand_path(location), underscore(@name)) : File.join(Dir.pwd, underscore(@name))
      @full_name  = git_config('user.name') || 'Your Full Name'
      @framework  = framework # TODO: javascript framework to load (maybe use an array to load several at once)
    end
    
    
    ##
    # Create
    #
    # create a new serve mockup
    #
    def create
      setup_base
      ['public/images', 'public/javascripts', 'public/stylesheets', 'sass'].each do |file|  
        make_dir_for(join_with_location(file)) 
      end
    end
    
    
    ##
    # Convert
    #
    # convert an existing compass project to a
    # server project
    #
    def convert
      setup_base
      move_file('images', 'public/')
      move_file('stylesheets', 'public/')
      move_file('javascripts', 'public/')
      move_file('src', 'sass')
    end
    
    
    private
      
      ##
      # Setup Base
      #
      # Files required for both a new server project
      # and for an existing compass project.
      #
      def setup_base
        ['tmp', 'views/layouts', 'public'].each { |file| make_dir_for(join_with_location(file)) }
        create_file(join_with_location('config.ru'),      config_ru)
        create_file(join_with_location('LICENSE'),        license)
        create_file(join_with_location('.gitignore'),     gitignore)
        create_file(join_with_location('compass.config'), compass_config)
        FileUtils.touch(join_with_location('README.mkd'))
        FileUtils.touch(join_with_location('tmp/restart.txt'))
      end
      
      
      ##
      # Compass config
      #
      # TODO: move to a file and load it from here
      #
      def compass_config
        <<-COMPASS_CONFIG
http_path             = '/'
http_stylesheets_path = '/stylesheets'
http_images_path      = '/images'
http_javascripts_path = '/javascripts'

sass_dir              = 'sass'
css_dir               = 'public/stylesheets'
images_dir            = 'public/images'
javascripts_dir       = 'public/javascripts'

relative_assets       = true

        COMPASS_CONFIG
      end
      
      
      ##
      # Config ru
      #
      # creates the config for rackup
      #
      def config_ru
        <<-CONFIG_RU
gem 'active_support', '~> 2.3.8'
gem 'serve',          '~> 0.11.7'

require 'serve'
require 'serve/rack'

require 'sass/plugin/rack'
require 'compass'

# The project root directory
root = ::File.dirname(__FILE__)

# Compass
Compass.add_project_configuration(root + '/compass.config')
Compass.configure_sass_plugin!

# Rack Middleware
use Rack::ShowStatus      # Nice looking 404s and other messages
use Rack::ShowExceptions  # Nice looking errors
use Sass::Plugin::Rack    # Compile Sass on the fly

# Rack Application
if ENV['SERVER_SOFTWARE'] =~ /passenger/i
  # Passendger only needs the adapter
  run Serve::RackAdapter.new(root + '/views')
else
  # We use Rack::Cascade and Rack::Directory on other platforms to handle static 
  # assets
  run Rack::Cascade.new([
    Serve::RackAdapter.new(root + '/views'),
    Rack::Directory.new(root + '/public')
  ])
end
        CONFIG_RU
      end
      
      ##
      # Git ignore file
      #
      def gitignore
        <<-IGNORE
## MAC OS
.DS_Store

## TEXTMATE
*.tmproj
tmtags

## EMACS
*~
\#*
.\#*

## VIM
*.swp

## PROJECT::GENERAL
coverage
rdoc
pkg

## PROJECT::SPECIFIC
*.gem
.rvmrc
        IGNORE
      end
      
      
      ##
      # Project license
      #
      def license
        <<-LICENSE
Copyright (c) #{Time.now.year} #{@full_name}

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
        LICENSE
      end
      
      
      ##
      # Create file
      #
      def create_file(path, contents)
        File.open(path, 'w+') { |f| f.puts contents }
      end
      
      
      ##
      # Make directory for a given path
      #
      def make_dir_for(path)
        FileUtils.mkdir_p(path)
      end
      
      
      ##
      # Move File
      #
      # e.g.
      #   move_file('images', 'public/')
      # 
      def move_file(from, to)
        FileUtils.mv(File.join(@location, from), File.join(@location, to)) if File.exists?(File.join(@location, from))
      end
      
      
      ##
      # Join paths together
      #
      def join_with_location(path)
        File.join(@location, path)
      end
      
      
      ##
      # Convert dashes and spaces to underscores
      #
      def underscore(string)
        string.gsub(/-|\s+/, '_')
      end
      
      
      ##
      # Grab data from the git config file if it exists
      #
      def git_config(key)
        value = `git config #{key}`.chomp
        value.empty? ? nil : value
      end
    

  end
end