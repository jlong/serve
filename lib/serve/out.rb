module Serve #:nodoc:
  
  # Utility methods for handling output to the terminal
  module Out #:nodoc:
    
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
      stderr.print(color_msg(:green, *args))
    end
    
    def log_action(name, message)
      print " " * (12 - name.length)
      print name
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
