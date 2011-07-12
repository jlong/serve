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
    end
    
    def self.create(options={})
      new(options).create
    end
    
    # Convert an existing Compass project to a Serve project
    def convert
      setup_base
      move_file 'images', 'public/'
      move_file 'stylesheets', 'public/'
      if File.directory? 'javascripts'
        move_file 'javascripts', 'public/'
      else
        make_path 'public/javascripts'
      end
      move_file 'src', 'stylesheets'
      install_javascript_framework @framework
      copy_readme
      note_old_compass_config
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
        
        files = []
        FileUtils.cd(source) { files = Dir.glob('**/*', File::FNM_DOTMATCH) }
        files.reject! { |f| %r{^\.{1,2}$|/\.{1,2}$|\.empty$}.match(f) }
        files.sort!
        
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
      
      def copy_readme
        create_file 'README.md', read_bootstrap_file('README.md'), :silent
      end
      
      # Display note about old compass config if it exists
      def note_old_compass_config
        old_config = @location + '/config.rb'
        if File.exists? old_config
          puts ""
          puts "============================================================================"
          puts " Please Note: You still need to copy your unique settings from config.rb to "
          puts " compass.config. Remove config.rb when you are finished."
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
      
      # Convert dashes and spaces to underscores
      def underscore(string)
        string.gsub(/-|\s+/, '_')
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
