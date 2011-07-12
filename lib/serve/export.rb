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
          @views = glob_path("#{@input}/views")
          @redirects, @views = @views.partition { |fn| fn =~ %r{\.redirect$} }
          @views.reject! { |fn| fn =~ /view_helpers.rb$/} # remove view_helpers.rb
          @public = glob_path("#{@input}/public")
        else
          @root = @input
          files = glob_path(@input)
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
      
      def compile_view(filename)
        from_path = rackified? ? "#{@input}/views/#{filename}" : "#{@input}/#{filename}"
        
        # request the path
        browser = Rack::Test::Session.new(Rack::MockSession.new(Serve::RackAdapter.new(@root)))
        browser.get filename, {}, {'REQUEST_URI' => "http://example.org/#{extract_request_path(filename)}"}
        response = browser.last_response
        
        # body and extension
        contents = response.body
        ext = extract_ext(filename)
        
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
        contents = %{<html><head><meta http-equiv="refresh" content="0;#{url}" /></head></html>}
        
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
      
      def extract_ext(path)
        if path =~ /(\.[A-Za-z]+)\.[A-Za-z]+$/
          $1
        elsif path =~ /(\.[A-Za-z]+)$/
          $1
        else
          ''
        end
      end
      
      def extract_request_path(filename)
        result = remove_ext(filename)
        result = result.sub(/index$/, '')
        result = result.sub(/\/$/, '')
        result
      end
      
      def rackified?
        File.directory?("#{@input}/views") && File.directory?("#{@input}/public")
      end
      
  end
  
  def self.export(options={})
    Exporter.new(options).process
  end
end