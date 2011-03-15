module Serve
  class FileResolver
    cattr_accessor :alternate_extensions
    
    def resolve(root, path)
      path = normalize_path(path)
      case
      when path.nil?
        return
      when path =~ /\.css\Z/ && !File.file?(File.join(root, path))  # if .css not found, try .scss, .sass:
        alternates = %w{.scss .sass}.map { |ext| path.sub(/\.css\Z/, ext) }
        sass_path = alternates.find do |p|
          File.file?(File.join(root, p))
        end
      when File.directory?(File.join(root, path)) 
        resolve(root, File.join(path, 'index'))
      else
        resolve_with_extension(root, path)
      end
    end
    
    private
      
      def normalize_path(path)
        path = File.join(path)       # path may be array
        path = path.sub(%r{/\Z}, '') # remove trailing slash
        path unless path =~ /\.\./   # guard against evil paths
      end
      
      def resolve_with_extension(root, path)
        full_path = File.join(root, path)
        if File.file?(full_path)
          path
        else
          result = Dir.glob(full_path + ".*").first
          result.sub(/^#{root}/, '').sub(/^\//, '') if result && File.file?(result)
        end
      end
      
      def find_extension(extensions_to_try, full_path)
        extensions_to_try.find do |ext|
          File.file?("#{full_path}.#{ext}")
        end
      end
    
    def self.instance
      @instance ||= FileResolver.new
    end
  end
  
  def self.resolve_filename(*args)
    Serve::FileResolver.instance.resolve(*args)
  end
end
