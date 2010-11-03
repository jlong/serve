module Serve #:nodoc:
  
  # Utility methods for handling output to the terminal
  module Out #:nodoc:
    
    def stdout
      @stdout ||= $stdout
    end
    
    def stdout=(value)
      @stdout = value
    end
    
    def stderr
      @stderr ||= $stderr
    end
    
    def stderr=(value)
      @stderr = value
    end
    
    def puts(*args)
      stdout.puts(*args)
    end
    
    def print(*args)
      stderr.print(*args)
    end
    
    def log_action(name, message)
      print " " * (12 - name.length)
      print name
      print "  "
      puts message
    end
    
  end
end
