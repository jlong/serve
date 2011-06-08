require 'pathname'

module Serve #:nodoc:
  
  # Utility methods for handling output to the terminal
  module Out #:nodoc:
    
    COLUMN_WIDTH = 12
    
    COLORS = {
      :clear  => 0,
      :red    => 31,
      :green  => 32,
      :yellow => 33
    }
    
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
      print " " * (COLUMN_WIDTH - name.length)
      print color_msg(:green, name)
      print "  "
      puts message
    end
    
    def log_error(name, message)
      print " " * (COLUMN_WIDTH - name.length)
      print color_msg(:red, name)
      print "  "
      puts message
    end
    
    def color_msg(pigment, *args)
      msg =  ''
      msg << color(pigment)
      msg << "#{args.join(' ')}"
      msg << color(:clear)
      msg
    end
    
    def color(pigment)
      "\e[#{COLORS[pigment.to_sym]}m"
    end
    
  end
  
end
