begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "serve"
    gem.summary = %Q{Serve is a small web server that makes it easy to serve ERB or HAML from any directory.}
    gem.description = %Q{Serve is a small Rack-based web server that makes it easy to serve ERB or HAML from any directory. Serve is an ideal tool for building HTML prototypes of Rails applications. Serve can also handle SASS, Textile, and Markdown if the appropriate gems are installed.}
    gem.email = "me@johnwlong.com"
    gem.homepage = "http://get-serve.com"
    gem.authors = ["John W. Long", "Adam I. Williams", "Robert Evans"]
    
    gem.files = FileList["[A-Z]*", "{bin,lib,rails,spec}/**/*"].exclude("tmp")
    
    gem.license = 'MIT'
    
    gem.post_install_message = [
      "Thanks for installing Serve! If you plan to use Serve with another",
      "template language (apart from ERB), don't forget to install it.",
      "",
      "If you want use Sass or Compass remember to install them, too!",
      "",
      "Serve doesn't install these dependencies by default, so that you can",
      "make your own decisions about what you want to use."
    ].join("\n")
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
