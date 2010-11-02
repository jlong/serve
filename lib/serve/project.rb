#
# Serve::Project.new(options).create
# Serve::Project.new(options).convert
#
#
module Serve
  class Project
    attr_reader :name, :location, :framework
    ACTIVESUPPORT_VERSION = '3.0.1'
    
    
    def initialize(options)
      @name       = options[:name]
      @location   = build_location(options[:directory])
      @full_name  = git_config('user.name') || 'Your Full Name'
      @framework  = options[:framework]
    end
    
    
    ##
    # Create
    #
    # create a new serve mockup
    #
    def create
      setup_base
      ['public/images', 'public/javascripts', 'public/stylesheets', 'sass'].each do |file|  
        make_path(join_with_location(file)) 
      end
      install_javascript_framework
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
      install_javascript_framework
    end
    
    
    private
      
      ##
      # Setup Base
      #
      # Files required for both a new server project
      # and for an existing compass project.
      #
      def setup_base
        ['tmp', 'public', 'views'].each { |file| make_path(join_with_location(file)) }
        create_file(join_with_location('config.ru'),       config_ru)
        create_file(join_with_location('LICENSE'),         license)
        create_file(join_with_location('.gitignore'),      gitignore)
        create_file(join_with_location('compass.config'),  compass_config)
        create_file(join_with_location('README.markdown'), readme)
        FileUtils.touch(join_with_location('tmp/restart.txt'))
      end
      
      
      ##
      # Install a JavaScript Framework
      #
      def install_javascript_framework
        return unless @framework
        Serve::JavaScript.new(@location).install(@framework)
      end
      
      
      ##
      # Compass config
      #
      # TODO: move to a file and load it from here
      #
      def compass_config
        read_template('compass_config')
      end
      
      
      ##
      # Config ru
      #
      # creates the config for rackup
      #
      def config_ru
        read_template('config_ru')
      end
      
      ##
      # Git ignore file
      #
      def gitignore
        read_template('gitignore')
      end
      
      
      ##
      # Project license
      #
      def license
        read_template('license')
      end
      
      
      ##
      # Project README
      #
      #
      def readme
        read_template('readme')
      end
      
      
      ##
      # Read and eval template
      #
      def read_template(name)
        contents = IO.read(File.dirname(__FILE__) + "/templates/#{name}")
        instance_eval("%{#{contents}}")
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
      def make_path(path)
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
      
      
      ##
      # Build the target directory
      #
      def build_location(directory)
        dir = File.expand_path(directory)
        return dir unless @name
        return File.join(dir, underscore(@name))
      end
    

  end
end