begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "serve"
    gem.summary = %Q{Serve is a small web server that makes it easy to serve ERB or HAML from any directory.}
    gem.description = %Q{Serve is a small web server (based on WEBrick) that makes it easy to serve ERB or HAML from any directory. Serve is an ideal tool for building HTML prototypes of Rails applications. Serve can also handle SASS, Textile, and Markdown if the appropriate gems are installed.}
    gem.email = "me@johnwlong.com"
    gem.homepage = "http://github.com/jlong/serve"
    gem.authors = ["John W. Long"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::RubyforgeTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end