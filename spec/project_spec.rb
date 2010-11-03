require File.dirname(__FILE__) + '/spec_helper.rb'
require 'serve/project'
require 'fileutils'

describe Serve::Project do
  
  describe "Creating a new serve project" do
    
    class SilentOut
      def puts(*args); end
      def print(*args); end
    end
    
    before(:all) do
      @options = {
        :name       => 'test_mockup',
        :directory  => File.dirname(__FILE__),
        :framework  => 'jquery'
      }
      
      @mockup       = Serve::Project.new(@options)
      @mockup.stdout = SilentOut.new
      @mockup.stderr = SilentOut.new
      
      @mockup_file  = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), @options[:name]))).relative_path_from(Pathname.new(Dir.pwd)).to_s
    end
    
    after(:all) do
      FileUtils.rm_rf(@mockup_file)
    end
    
    it "should have a project name" do
      @mockup.name.should == 'test_mockup'
    end
    
    it "should have a project directory" do
      @mockup.location.should == @mockup_file
    end
    
    it "should have a framework" do
      @mockup.framework.should == 'jquery'
    end
    
    describe "The created files" do
      before(:all) do
        @mockup.create
      end
      
      it "should create a directory" do
        File.exists?(@mockup_file).should be_true
      end
      
      it "should have a public directory" do
        File.exists?(File.join(@mockup_file, 'public')).should be_true
      end
      
      it "should have a javascript directory" do
        File.exists?(File.join(@mockup_file, 'public/javascripts')).should be_true
      end
      
      it "should have a stylesheets directory" do
        File.exists?(File.join(@mockup_file, 'public/stylesheets')).should be_true
      end
      
      it "should have an images directory" do
        File.exists?(File.join(@mockup_file, 'public/images')).should be_true
      end
      
      it "should have a sass directory" do
        File.exists?(File.join(@mockup_file, 'sass')).should be_true
      end
      
      it "should have a tmp directory" do
        File.exists?(File.join(@mockup_file, 'tmp')).should be_true
      end
      
      it "should have a views directory" do
        File.exists?(File.join(@mockup_file, 'views')).should be_true
      end
      
      it "should have config.ru file" do
        File.exists?(File.join(@mockup_file, 'config.ru')).should be_true
      end
      
      it "should have a compass.config file" do
        File.exists?(File.join(@mockup_file, 'compass.config')).should be_true
      end
      
      it "should have a LICENSE file" do
        File.exists?(File.join(@mockup_file, 'LICENSE')).should be_true
      end
      
      it "should have a dot gitignore file" do
        File.exists?(File.join(@mockup_file, '.gitignore')).should be_true
      end
      
      it "should have a README file" do
        File.exists?(File.join(@mockup_file, 'README.markdown')).should be_true
      end
      
      it "should have a restart file" do
        File.exists?(File.join(@mockup_file, 'tmp/restart.txt')).should be_true
      end
    end
    
  end
end