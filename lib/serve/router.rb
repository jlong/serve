module Serve
  module Router
    
    # Resolve a path to a valid file name in root path. Return nil if no
    # file exists for that path.
    def self.resolve(root, path)
      path = normalize_path(path)
      
      return if path.nil? # If it's not a valid path, return nothing.
      
      full_path = File.join(root, path)
      
      case
      when File.file?(full_path)
        # A file exists! Return the matching path.
        path
      when File.directory?(full_path) 
        # It's a directory? Try a directory index.
        resolve(root, File.join(path, 'index'))
      when path.ends_with?('.css')
        # CSS not found? Try SCSS or Sass.
        alternates = %w{.scss .sass}.map { |ext| path.sub(/\.css\Z/, ext) }
        sass_path = alternates.find do |p|
          File.file?(File.join(root, p))
        end      
      else
        # Still no luck? Check to see if a file with an extension exists by that name.
        # TODO: Return a path with an extension based on priority, not just the first found.
        result = Dir.glob(full_path + ".*", File::FNM_CASEFOLD).first
        result.sub(/^#{root}/, '').sub(/^\//, '') if result && File.file?(result)
      end
    end
    
    private
      
      def self.normalize_path(path)
        path = File.join(path)       # path may be array
        path = path.sub(%r{/\Z}, '') # remove trailing slash
        path unless path =~ /\.\./   # guard against evil paths
      end
      
  end
end
