require 'active_support'

module Serve
  mattr_accessor :file_resolver
  
  class FileResolver
    cattr_accessor :alternate_extensions
    self.alternate_extensions = %w(html txt text haml erb rhtml html.erb html.haml textile markdown email redirect)
    
    def resolve(root, path)
      return nil if path.nil?
      path = File.join(path) # path may be array
      return nil if path =~ /\.\./
      path = path.sub(%r{/\Z}, '')
      if path =~ /\.css\Z/ && !File.file?(File.join(root, path))
        sass_path = path.sub(/\.css\Z/, '.sass')
        sass_path if File.file?(File.join(root, sass_path))
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