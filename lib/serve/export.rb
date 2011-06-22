require 'active_support/all'
require 'serve/out'
require 'serve/path'
require 'serve/rack'
require 'fileutils'
require 'rack/test'

module Serve
  class Exporter
    
    def initialize(options={})
      @input  = normalize_path(options[:input])
      @output = normalize_path(options[:output])
    end
    
    def process
      compile_compass_sass
      collect_files
      compile_views
      compile_redirects
      copy_remaining
    end
    
    private
      
      include Serve::Out
      include Serve::Path
      
      def collect_files
        if rackified?
          @root = "#{@input}/views"
          @views = files_from_path("#{@input}/views")
          @redirects, @views = @views.partition { |fn| fn =~ %r{\.redirect$} }
          @views.reject! { |fn| fn =~ /view_helpers.rb$/} # remove view_helpers.rb
          @public = files_from_path("#{@input}/public")
        else
          @root = @input
          files = files_from_path(@input)
          extensions = Serve::DynamicHandler.extensions
          @views, files = files.partition { |fn| fn =~ %r{#{extensions.join('|')}$} }
          files.reject! { |fn| fn =~ /view_helpers.rb$/} # remove view_helpers.rb
          @redirects, @public = files.partition { |fn| fn =~ %r{\.redirect$} }
        end
        @views.reject! { |v| v =~ /(^_|\/_)/ }           # remove partials
      end
      
      def compile_compass_sass
        if rackified?
          `compass compile -c '#{@input}/compass.config' '#{@input}'`
          log_action 'compiled', 'sass files'
        end
      end
      
      def compile_views
        @views.each { |v| compile_view(v) }
      end
      
      def compile_redirects
        @redirects.each { |r| compile_redirect(r) }
      end
      
      def copy_remaining
        @public.each { |fn| copy_file(fn) }
      end
      
      def files_from_path(path)
        result = nil
        FileUtils.cd(path) do
          result = Dir["**/*"]
          result.reject! { |fn| File.directory?(fn) }
        end
        result
      end
      
      def compile_view(filename)
        from_path = rackified? ? "#{@input}/views/#{filename}" : "#{@input}/#{filename}"
        
        # request the path
        browser = Rack::Test::Session.new(Rack::MockSession.new(Serve::RackAdapter.new(@root)))
        browser.get filename
        response = browser.last_response
        
        # body and extension
        contents = response.body
        ext = extract_ext(response.content_type)
        
        # write contents
        to_path   = "#{@output}/#{remove_ext(filename)}#{ext}"
        ensure_path to_path
        File.open(to_path, 'w+') { |f| f.puts contents }
        
        log_action "compiled", to_path
      rescue => e
        log_error "failed", "#{from_path}\n#{e.message}\n#{e.backtrace.join("\n")}"
      end
      
      def compile_redirect(filename)
        from_path = rackified? ? "#{@input}/views/#{filename}" : "#{@input}/#{filename}"
        to_path   = "#{@output}/#{remove_ext(filename)}.html"
        
        ensure_path to_path
        
        lines = IO.read(from_path).strip.split("\n")
        url = lines.pop.strip
        contents = %{<html><head><meta http-equiv="refresh" content="0;#{url}" /></head><body>#{lines.join("\n")}</body</html>}
        
        File.open(to_path, 'w+') { |f| f.puts contents }
        
        log_action "compiled", to_path
      rescue => e
        log_error "failed", "#{from_path}\n#{e.message}\n#{e.backtrace.join("\n")}"
      end
      
      def copy_file(filename)
        from_path = rackified? ? "#{@input}/public/#{filename}" : "#{@input}/#{filename}"
        to_path   = "#{@output}/#{filename}"
        
        ensure_path to_path
        
        FileUtils.cp from_path, to_path
        
        log_action "copied", to_path
      end
      
      def ensure_path(path)
        dirname = normalize_path(File.dirname(path))
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
          log_action "created", dirname
        end
      end
      
      def remove_ext(path)
        if path =~ /^(.*?)\.[A-Za-z]+[A-Za-z.]*$/
          $1
        else
          path
        end
      end
      
      def extract_ext(content_type)
        case content_type
        when %r{text/html}
          ".html"
        when %r{text/css}
          ".css"
        when %r{text/javascript}
          ".js"
        else
          raise content_type.inspect
        end
      end
      
      def rackified?
        @rackified ||= File.directory?("#{@input}/views") && File.directory?("#{@input}/public")
      end
  end
  
  def self.export(options={})
    Exporter.new(options).process
  end
end