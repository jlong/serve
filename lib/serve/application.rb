require 'active_support/all'
require 'serve/rack'

module Serve
  class Application
    class InvalidArgumentsError < StandardError; end
    
    attr_accessor :options
    
    def self.run(args = ARGV)
      new.run(args)
    end
    
    def initialize
      self.options = {}
    end
    
    def run(args = ARGV)
      @options = parse(args)
      case
      when options[:create]
        require 'serve/project'
        Serve::Project.create(options[:create])
      when options[:convert]
        require 'serve/project'
        Serve::Project.convert(options[:convert])
      when options[:export]
        require 'serve/export'
        Serve.export(options[:export])
      when options[:version]
        puts version
      when options[:help]
        puts help
      else
        Dir.chdir(options[:root])
        case
        when rails_app?
          run_rails_app
        when rack_app?
          run_rack_app
        else
          run_server
        end
      end
    rescue InvalidArgumentsError
      puts "invalid arguments"
      puts
      puts help
    end
    
    def parse(args)
      args = normalize_args(args)
      options[:help]        = extract_boolean(args, '-h', '--help')
      options[:version]     = extract_boolean(args, '-v', '--version')
      options[:create]      = extract_create(args)
      options[:convert]     = extract_convert(args)
      options[:export]      = extract_export(args)
      options[:environment] = extract_environment(args)
      options[:root]        = extract_root(args)
      options[:address]     = extract_address(args)
      options[:port]        = extract_port(args)
      raise InvalidArgumentsError if args.size > 0
      options
    end
    
    def version
      "Serve #{Serve.version}"
    end
    
    def help
      program = File.basename($0)
      [
        "Serve is a rapid prototyping framework for Web applications. This is a basic ",
        "help message containing pointers to more information.",
        "  ",
        "Usage:",
        "  #{program} -h/--help",
        "  #{program} -v/--version",
        "  #{program} [port] [environment] [directory]",
        "  #{program} [address:port] [environment] [directory]",
        "  #{program} [address] [port] [environment] [directory]",
        "  #{program} command [arguments] [options]",
        "  ",
        "Examples:",
        "  #{program}                        # launch server in current directory",
        "  #{program} 2100                   # launch server on port 2100",
        "  #{program} project                # launch server for project directory",
        "  #{program} create project         # new structured project in project dir",
        "  #{program} convert project        # convert a Compass project in directory",
        "  #{program} export project output  # export project to output directory",
        "  ",
        "Description:",
        "  Starts a web server on the specified address and port with its document root ",
        "  set to the current working directory. (Optionally, you can specify the ",
        "  directory as the last parameter.) By default the command uses 0.0.0.0 for ",
        "  the address and 4000 for the port. This means that once the command has ",
        "  been started you can access the documents in the current directory with any ",
        "  web browser at:",
        "  ",
        "    http://localhost:4000/",
        "  ",
        "  If the haml, slim, redcloth, or bluecloth gems are installed the command can ",
        "  handle Haml, Slim, Sass, SCSS, Textile, and Markdown for documents with haml, ",
        "  slim, sass, scss, textile, and markdown file extensions.",
        "  ",
        "  If the Rails command script/server exists in the current directory the ",
        "  script will start that instead.",
        "  ",
        "  If a Rack configuration file (config.ru) exists in the current directory the ",
        "  script will start that using the `rackup` command.",
        "  ",
        "  A Rails or Rack app will start with the environment specified or the ",
        "  development environment if none is specified. Rails and Rack apps are ",
        "  started by default on port 3000.",
        "  ",
        "Additional Commands:",
        "  In addition the functionality listed above the following commands are ",
        "  supported by Serve.",
        "  ",
        "  create",
        "    Creates a new Rack-based Serve project with support for Haml, Sass, and",
        "    Compass with the appropriate directory structure and configuration files.",
        "  ",
        "  convert",
        "    Converts an existing Compass project into a Rack-based Serve project.",
        "   ",
        "  export",
        "    Exports a Serve project to regular HTML and CSS.",
        "   ",
        "Options:",
        "  -j, --javascript  The name of the JavaScript Framework you'd like to use.",
        "                    (Only for create and convert.)",
        "  -t, --template    The name of the template project to base the project on.",
        "                    Builtins: blank, default. (Only for create.)",
        "  -h, --help        Show this message and quit.",
        "  -v, --version     Show the program version number and quit.",
        "  ",
        "Further information:",
        "  http://get-serve.com/documentation"
      ].join("\n")
    end
    
    private
      
      def normalize_args(args)
        args = args.join(' ')
        args.gsub!(%r{http://}, '')
        args.split(/[ :]/).compact
      end
      
      def extract_boolean(args, *opts)
        opts.each do |opt|
          return true if args.delete(opt)
        end
        false
      end
      
      def extract_environment(args)
        args.delete('production') || args.delete('test') || args.delete('development') || 'development'
      end
      
      def extract_port(args)
        (args.delete(args.find {|a| /^\d\d\d*$/.match(a) }) || ((rails_app? or rack_app?) ? 3000 : 4000)).to_i
      end
      
      def extract_address(args)
        args.delete(args.find {|a| /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(a) }) || '0.0.0.0'
      end
      
      def extract_root(args)
        args.reverse.each do |dir|
          if File.directory?(dir)
            args.delete(dir)
            return File.expand_path(dir)
          end
        end
        '.'
      end
      
      def extract_arg_and_value(args, opts)
        opts.each do |opt|
          index = args.index(opt)
          next unless index
          key = args.delete_at(index)
          value = args[index]
          if value !~ /^-/
            args.delete_at(index)
            return value 
          end
        end
        nil
      end
      
      def extract_javascript_framework(args)
        extract_arg_and_value args, %w(-j --javascript)
      end
      
      def extract_template(args)
        extract_arg_and_value args, %w(-t --template)
      end
      
      def extract_create(args)
        if args.delete('create')
          framework = extract_javascript_framework(args)
          template  = extract_template(args)
          directory = args.pop || '.'
          {
            :directory => directory,
            :framework => framework,
            :template  => template
          }
        end
      end
      
      def extract_convert(args)
        if args.delete('convert')
          framework = extract_javascript_framework(args)
          directory = args.pop || '.'
          {
            :directory => directory,
            :framework => framework 
          }
        end
      end
      
      def extract_export(args)
        if args.delete('export')
          input, output = args.shift, args.shift
          input, output = '.', input if output.nil?
          output ||= 'html'
          {
            :input => input,
            :output => output
          }
        end
      end
      
      def rails_script_server
        @rails_server_script ||= options[:root] + '/script/server'
      end
      
      def rails_app?
        File.file?(rails_script_server) and File.executable?(rails_script_server)
      end
      
      def run_rails_app
        system "#{rails_script_server} -p #{options[:port]} -b #{options[:address]} -e #{options[:environment]}"
      end
      
      def rack_config
        @rack_config ||= options[:root] + '/config.ru'
      end
      
      def rack_app?
        File.file?(rack_config)
      end
      
      def run_rack_app
        system "rackup -p #{options[:port]} -o #{options[:address]} -E #{options[:environment]} '#{rack_config}'"
      end
      
      def run_server
        root = options[:root]
        app = Rack::Builder.new do
          use Rack::CommonLogger
          use Rack::ShowStatus
          use Rack::ShowExceptions
          run Rack::Cascade.new([
            Serve::RackAdapter.new(root),
            Rack::Directory.new(root)
          ])
        end
        begin
          # Try Thin
          thin = Rack::Handler.get('thin')
          thin.run app, :Port => options[:port], :Host => options[:address] do |server|
            puts "Thin #{Thin::VERSION::STRING} available at http://#{options[:address]}:#{options[:port]}"
          end
        rescue LoadError
          begin
            # Then Mongrel
            mongrel = Rack::Handler.get('mongrel')
            mongrel.run app, :Port => options[:port], :Host => options[:address] do |server|
              puts "Mongrel #{Mongrel::Const::MONGREL_VERSION} available at http://#{options[:address]}:#{options[:port]}"
            end
          rescue LoadError
            # Then WEBrick
            puts "Install Mongrel or Thin for better performance."
            webrick = Rack::Handler.get('webrick')
            webrick.run app, :Port => options[:port], :Host => options[:address] do |server|
              trap("INT") { server.shutdown }
            end
          end
        end
      end
  end
end
