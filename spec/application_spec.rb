require File.dirname(__FILE__) + '/spec_helper.rb'
require 'serve/application'

describe Serve::Application do
  
  before :each do
    @app = Serve::Application.new
    @options = {
      :help         => false,
      :version      => false,
      :environment  => 'development',
      
      :port         => 4000,
      :address      => '0.0.0.0',
      :root         => ".",
      
      :convert      => nil,
      :create       => nil,
      :export       => nil
    }
  end
  
  describe "parsing" do
    
    it "no arguments" do
      parse('').should == @options
    end
    
    it "with only the port" do
      parse('2000')[:port].should == 2000
    end
    
    it "with the port and address" do
      parse('1.1.1.1 2000').should == @options.update(:address => "1.1.1.1", :port=>2000)
      parse('1.1.1.1:2000').should == @options.update(:address => "1.1.1.1", :port=>2000)
    end
    
    it "with the port, address, and protocol" do
      parse('http://1.1.1.1:2000').should == @options.update(:address => "1.1.1.1", :port=>2000)
    end
    
    it "help" do
      parse('')[:help].should be_false
      parse('-h')[:help].should be_true
      parse('--help')[:help].should be_true
    end
    
    it "version" do
      parse('')[:version].should be_false
      parse('-v')[:version].should be_true
      parse('--version')[:version].should be_true
    end
    
    it "environment" do
      parse('')[:environment].should == "development"
      parse('production')[:environment].should == "production"
      parse('test')[:environment].should == "test"
      parse('development')[:environment].should == "development"
    end
    
    it "working directory" do
      parse('')[:root].should == '.'
      dir = File.dirname(__FILE__)
      parse(dir)[:root].should == File.expand_path(dir)
    end
    
    describe "create" do
      it "with standard arguments" do
        params = parse('create newapp')[:create]
        params[:directory].should == 'newapp'
        params[:framework].should be_nil
        params[:template].should be_nil
      end
      
      it "with no arguments" do
        params = parse('create')[:create]
        params[:directory].should == '.'
        params[:framework].should be_nil
        params[:template].should be_nil
      end
      
      it "with a javascript framework" do
        params = parse('create newapp -j jquery')[:create]
        params[:directory].should == 'newapp'
        params[:framework].should == 'jquery'
      end
      
      it "with a template" do
        params = parse('create newapp --template blank')[:create]
        params[:directory].should == 'newapp'
        params[:template].should == 'blank'
      end
    end
    
    describe "convert" do
      it "with standard arguments" do
        params = parse('convert /Users/user')[:convert]
        params[:directory].should == '/Users/user'
        params[:framework].should be_nil
      end
      
      it "with no arguments" do
        params = parse('convert')[:convert]
        params[:directory].should == '.'
        params[:framework].should be_nil
      end
      
      it "with a javascript framework" do
        params = parse('convert /Users/user --javascript mootools')[:convert]
        params[:directory].should == '/Users/user'
        params[:framework].should == 'mootools'
      end
    end
    
    describe "export" do
      it "with standard arguments" do
        params = parse('export input output')[:export]
        params[:input].should == 'input'
        params[:output].should == 'output'
      end
      
      it "export with just an output directory" do
        params = parse('export output')[:export]
        params[:input].should == '.'
        params[:output].should == 'output'
      end
      
      it "export with no arguments" do
        params = parse('export')[:export]
        params[:input].should == '.'
        params[:output].should == 'html'
      end
    end
    
    it "with invalid arguments" do
      lambda { parse('--invalid') }.should raise_error(Serve::Application::InvalidArgumentsError)
      lambda { parse('invalid') }.should raise_error(Serve::Application::InvalidArgumentsError)
    end
    
    private
    
      def parse(*args)
        args = args.split(' ')
        @app.parse(*args)
      end
    
  end
  
  describe "running" do
    
  end
  
end