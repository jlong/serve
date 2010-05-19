require 'active_support'
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
      when options[:version]
        puts version
      when options[:help]
        puts help
      else
        Dir.chdir(options[:root])
        if rails_app?
          run_rails_app
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
        "Usage:",
        "  #{program} [port] [environment] [directory]",
        "  #{program} [address:port] [environment] [directory]",
        "  #{program} [address] [port] [environment] [directory]",
        "  #{program} [options]",
        "  ",
        "Description:",
        "  Starts a WEBrick server on the specified address and port with its document ",
        "  root set to the current working directory. (Optionally, you can specify the ",
        "  directory as the last parameter.) By default the command uses 0.0.0.0 for ",
        "  the address and 4000 for the port. This means that once the command has ",
        "  been started you can access the documents in the current directory with any ",
        "  Web browser at:",
        "  ",
        "    http://localhost:4000/",
        "  ",
        "  If the haml, redcloth, or bluecloth gems are installed the command can serve ",
        "  Haml, Sass, SCSS, Textile, and Markdown for documents with haml, sass, scss, ",
        "  textile, and markdown file extensions.",
        "  ",
        "  If the Rails command script/server exists in the current directory the ",
        "  script will start that instead with the specified environment or the ",
        "  development environment if none is specified. Rails apps are started by ",
        "  default on port 3000.",
        "  ",
        "Options:",
        "  -h, --help      Show this message and quit.",
        "  -v, --version   Show the program version number and quit."
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
        (args.delete(args.find {|a| /^\d\d\d*$/.match(a) }) || (rails_app? ? 3000 : 4000)).to_i
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
        Dir.pwd
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
        webrick = Rack::Handler.get('webrick')
        webrick.run app, :Port => options[:port], :BindAddress => options[:address]
      end
  end
end