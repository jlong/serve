require File.dirname(__FILE__) + '/spec_helper.rb'
require 'serve/project'
require 'fileutils'

describe Serve::Project do
  
  describe "Creating a new Serve project" do
    
    class SilentOut
      def puts(*args); end
      def print(*args); end
    end
    
    include Serve::Path
    
    before(:all) do
      @options = {
        :port       => 4000,
        :address    => '0.0.0.0',
        :directory  => 'serve_project_for_tests',
        :framework  => 'jquery'
      }
      
      @project        = Serve::Project.new(@options)
      @project.stdout = SilentOut.new
      @project.stderr = SilentOut.new
      
      @project_root  = normalize_path(@options[:directory])
    end
    
    after :all do
      FileUtils.rm_rf @project_root
    end
    
    it "should have a project directory" do
      @project.location.should == 'serve_project_for_tests'
    end
    
    it "should have a framework" do
      @project.framework.should == 'jquery'
    end
    
    it "should have a default template" do
      @project.template.should == 'default'
    end
    
    describe "The created files" do
      before(:all) do
        @project.create
      end
      
      it "should create a directory" do
        exists?('.').should be_true
      end
      
      it "should have a public directory" do
        exists?('public').should be_true
      end
      
      it "should have a javascript directory" do
        exists?('public/javascripts').should be_true
      end
      
      it "should have a stylesheets directory" do
        exists?('public/stylesheets').should be_true
      end
      
      it "should have an images directory" do
        exists?('public/images').should be_true
      end
      
      it "should have a sass directory" do
        exists?('stylesheets').should be_true
      end
      
      it "should have a tmp directory" do
        exists?('tmp').should be_true
      end
      
      it "should have a views directory" do
        exists?('views').should be_true
      end
      
      it "should have config.ru file" do
        exists?('config.ru').should be_true
      end
      
      it "should have a compass.config file" do
        exists?('compass.config').should be_true
      end
      
      it "should have a dot gitignore file" do
        exists?('.gitignore').should be_true
      end
      
      it "should have a restart file" do
        exists?('tmp/restart.txt').should be_true
      end
      
      def exists?(filename)
        File.exists?(File.join(@project_root, filename))
      end
    end
    
  end
end