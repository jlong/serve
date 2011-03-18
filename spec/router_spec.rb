require File.dirname(__FILE__) + '/spec_helper.rb'
require 'serve/router'

describe Serve::Router do
  
  before do
    @root = File.dirname(__FILE__) + '/fixtures'
  end
  
  it 'should not resolve bad file names' do
    resolve('404').should be_nil
  end
  
  it 'should resolve file names' do
    resolve('hello.html').should == 'hello.html'
  end
  
  it 'should resolve filenames without extensions' do
    resolve('hello').should == 'hello.html'
    resolve('hello/').should == 'hello.html'
  end
  
  it 'should resolve directory indexes' do
    resolve('directory').should == 'directory/index.html'
    resolve('directory/').should == 'directory/index.html'
  end
  
  it 'should resolve references to css files to sass if css does not exist' do
    resolve('stylesheets/application.css').should == 'stylesheets/application.sass'
  end
  
  it 'should not resolve paths that attempt to climb up the directory tree' do
    resolve('../CHANGELOG.rdoc').should be_nil
    resolve('directory/../hello.html').should be_nil
  end
  
  it 'should resolve files with various extensions' do
    @root = File.dirname(__FILE__) + '/../tmp/'
    random_extension = %w(a b c d e f g).shuffle[1..4].join
    path = "test" 
    full_path = path + "." + random_extension
    FileUtils.touch(@root + full_path)
    resolve(path).should == full_path
    resolve(path + "/").should == full_path
    FileUtils.rm(@root + full_path)
  end
  
  it 'should resolve files without case sensitivity' do
    resolve('HELLO').should == 'hello.html'
  end
  
  it 'should resolve directories without case sensitivity' do
    resolve('DIRECTORY').should == 'directory/index.html'
  end
  
  def resolve(name)
    Serve::Router.resolve(@root, name)
  end
  
end