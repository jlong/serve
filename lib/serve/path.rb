require 'pathname'

module Serve #:nodoc:
  module Path #:nodoc:
    
    # Normalize a path relative to the current working directory
    def normalize_path(*paths)
      path = File.join(*paths)
      Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(Dir.pwd)).to_s
    end
    
  end
end