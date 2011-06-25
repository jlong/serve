module Serve #:nodoc:
  
  class JsonHandler < FileTypeHandler #:nodoc:
    extension 'json', 'yml'
    
    def parse(string)
      case syntax
        when :yml then YAML.load(string).to_json
        when :json then string.dup
      end
    end
    
    def syntax
      ext = File.extname(@script_filename)
      if ext == '.json'
        :json
      else
        :yml
      end
    end

    def content_type
      'application/json'
    end
  end
end