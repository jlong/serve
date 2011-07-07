require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

load 'tasks/jeweler.rake'
load 'tasks/rdoc.rake'
load 'tasks/rspec.rake'
load 'tasks/website.rake'
load 'tasks/undefine.rake'

task :default => :spec