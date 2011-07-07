require 'rdoc/task'

RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Serve #{version}"
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end