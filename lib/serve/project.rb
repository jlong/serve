require 'fileutils'
require 'serve/out'
require 'serve/path'
require 'serve/javascripts'

module Serve #:nodoc:
  #
  # Serve::Project.new(options).create
  # Serve::Project.new(options).convert
  #
  class Project #:nodoc:
    attr_reader :location, :framework, :template
    
    def initialize(options)
      @location   = normalize_path(options[:directory])
      @framework  = options[:framework]
      @template   = options[:template] || 'default'
    end
    
    # Create a new Serve project
    def create
      setup_base
      %w(
        public/images
        public/javascripts
        public/stylesheets
        stylesheets
      ).each { |path| make_path path } 
      copy_project_template @template
      install_javascript_framework @framework
      copy_readme
      post_create_message
    end
    
    def self.create(options={})
      new(options).create
    end
    
    # Convert an existing Compass project to a Serve project
    def convert
      setup_base
      move_file 'images', 'public/'
      move_file 'stylesheets', 'public/'
      if File.directory? "#{@location}/javascripts"
        move_file 'javascripts', 'public/'
      else
        make_path 'public/javascripts'
      end
      if File.directory? "#{@location}/src"
        move_file 'src', 'stylesheets'
      elsif File.directory? "#{@location}/sass"
        move_file 'sass', 'styleheets'
      end
      install_javascript_framework @framework
      copy_readme
      post_convert_message
    end
    
    def self.convert(options={})
      new(options).convert
    end
    
    private
      
      include Serve::Out
      include Serve::Path
      include Serve::JavaScripts
      
      # Files required for both a new server project and for an existing compass project.
      def setup_base
        make_path
        %w(
          public
          tmp
          views
        ).each { |path| make_path path }
        create_file 'Gemfile',         read_bootstrap_file('Gemfile', true)
        create_file 'config.ru',       read_bootstrap_file('config.ru')
        create_file '.gitignore',      read_bootstrap_file('gitignore')
        create_file 'compass.config',  read_bootstrap_file('compass.config')
        create_empty_file 'tmp/restart.txt'
      end
      
      # Copy files from project template
      def copy_project_template(name)
        source = lookup_template_directory(name)
        raise 'invalid template' unless source
        
        files = glob_path(source, true)
        
        files.each do |filename|
          from_path = "#{source}/#{filename}"
          to_path = "#{@location}/#{filename}"
          if File.directory? from_path
            make_path filename
          else
            if File.file? to_path
              log_action "exists", to_path
            else
              log_action "create", to_path
              FileUtils.cp from_path, to_path
            end
          end
        end
      end
      
      # Install a JavaScript framework if one was specified
      def install_javascript_framework(framework)
        if framework
          if valid_javascript_framework?(framework)
            path = "#{@location}/public/javascripts"
            filename = javascript_filename(framework, path)
            if File.exists? filename
              log_action 'exists', filename
            else
              log_action 'install', filename
              fetch_javascript framework, path
            end
          else
            puts "*** #{framework} javascript framework not supported. ***"
            puts "Supported frameworks: #{ supported_javascript_frameworks.join(', ') }"
          end
        end
      end
      
      # Copy readme file if not included in template
      def copy_readme
        create_file 'README.md', read_bootstrap_file('README.md'), :silent
      end
      
      # Display post create message
      def post_create_message(action_message = "You created a new Serve project.")
        puts ""
        puts "Woohoo! #{action_message}"
        puts ""
        puts "A couple of basic files are in place ready for you to edit."
        puts "Remember to edit the project Gemfile and run:"
        puts ""
        puts "    bundle install"
        puts ""
        puts "To start serving your project, run:"
        puts ""
        puts "    cd \"#{@location}\""
        puts "    serve"
        puts ""
        puts "Then go to http://localhost:4000 in your web browser."
        puts ""
        puts "Have fun!"
        puts ""
      end
      
      # Display post convert message
      def post_convert_message
        post_create_message "You converted your Compass project to a Serve project."
        if File.exists? "#{@location}/config.rb"
          puts "============================================================================"
          puts "Please Note: You still need to copy your unique settings from config.rb to "
          puts "compass.config. Remove config.rb when you are finished."
          puts "============================================================================"
          puts ""
        end
      end
      
      # Read and optionally eval a bootstrap template by name
      def read_bootstrap_file(name, eval = false)
        contents = IO.read(normalize_path(File.dirname(__FILE__), "bootstrap", name))
        eval ? instance_eval("%{#{contents}}") : contents
      end
      
      # Create a file with contents
      def create_file(file, contents, exists=:noisy)
        path = "#{@location}/#{file}"
        unless File.exists? path
          log_action "create", path
          File.open(path, 'w+') { |f| f.puts contents }
        else
          log_action "exists", path if exists == :noisy
        end
      end
      
      # Create an empty file
      def create_empty_file(file)
        path = "#{@location}/#{file}"
        FileUtils.touch(path)
      end
      
      # Make every directory in a given path
      def make_path(path=nil)
        path = File.join(*[@location, path].compact)
        unless File.exists? path
          log_action "create", path
          FileUtils.mkdir_p(path)
        else
          log_action "exists", path
        end
      end
      
      # Move a file from => to (relative to the project location)
      def move_file(from, to)
        from_path = "#{@location}/#{from}"
        to_path = "#{@location}/#{to}"
        if File.exists? from_path
          to = to + from if to[-1..-1] == "/"
          log_action "move", "#{@location}/{#{from} => #{to}}"
          FileUtils.mv from_path, to_path
        end
      end
      
      def default_templates_directory
        "#{File.dirname(__FILE__)}/templates"
      end
      
      def lookup_template_directory(name)
        path = "#{default_templates_directory}/#{name}"
        path = normalize_path(name) unless File.directory?(path)
        path if File.directory?(path)
      end
  end
end
