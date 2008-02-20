module Serve #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 9
    TINY  = 6

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
  
  def self.version
    VERSION::STRING
  end
end
