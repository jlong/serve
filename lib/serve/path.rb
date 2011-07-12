require 'pathname'
require 'fileutils'

module Serve #:nodoc:
  module Path #:nodoc:
    
    # Normalize a path relative to the current working directory
    def normalize_path(*paths)
      path = File.join(*paths)
      Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(Dir.pwd)).to_s
    end
    
    # Retrieve all files from a path
    def glob_path(path, directories = false)
      result = nil
      
      FileUtils.cd(path) do
        # glob files
        result = Dir.glob("**/*", File::FNM_DOTMATCH)
        
        # reject the directories
        result.reject! { |fn| File.directory?(fn) } unless directories
        
        # reject dot files or .empty
        result.reject! { |fn| %r{(^|/)(\.{1,2}|\.empty)$}.match(fn) }
        
        # reject git files (allow .gitignore)
        result.reject! { |fn| %r{\.git(/|$)}.match(fn) }
      end
      
      result.sort!
      
      result
    end
    
  end
end