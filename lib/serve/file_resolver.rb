module Serve
  mattr_accessor :file_resolver
  
  class FileResolver
    cattr_accessor :alternate_extensions
    self.alternate_extensions = %w(htm html txt text xml atom rss rdf haml erb rhtml slim html.erb html.haml html.slim textile markdown email redirect)
    
    def resolve(root, path)
      return nil if path.nil?
      path = File.join(path) # path may be array
      return nil if path =~ /\.\./
      path = path.sub(%r{/\Z}, '')
      if path =~ /\.css\Z/ && !File.file?(File.join(root, path))  # if .css not found, try .scss, .sass:
        alternates = %w{.scss .sass}.map { |ext| path.sub(/\.css\Z/, ext) }
        sass_path = alternates.find do |p|
          File.file?(File.join(root, p))
        end
      elsif File.directory?(File.join(root, path))
        resolve(root, File.join(path, 'index'))
      else
        resolve_with_extension(root, path)
      end
    end
    
    def resolve_with_extension(root, path)
      full_path = File.join(root, path)
      if File.file?(full_path)
        path
      else
        if extension = find_extension(alternate_extensions, full_path)
          "#{path}.#{extension}"
        end
      end
    end
    
    def find_extension(extensions_to_try, full_path)
      extensions_to_try.find do |ext|
        File.file?("#{full_path}.#{ext}")
      end
    end
  end
  
  self.file_resolver = FileResolver.new
  
  def self.resolve_file(root, path)
    file_resolver.resolve(root, path)
  end
end
