require File.dirname(__FILE__) + '/spec_helper.rb'
require 'serve/application'

describe Serve::Application do
  
  before :each do
    @app = Serve::Application.new
    @defopts = {
      :help         => false,
      :version      => false,
      :environment  => 'development',
      :port         => 4000,
      :address      => '0.0.0.0',
      :root         => Dir.pwd,
      :convert      => nil,
      :create       => nil
    }
  end
  
  describe "parsing" do
    it "should parse no arguments" do
      @app.parse([]).should == @defopts
    end
    
    it "should parse with only the port" do
      @app.parse(["2000"])[:port].should == 2000
    end
    
    it "should parse with the port and address" do
      @app.parse(["1.1.1.1", "2000"]).should ==
        @defopts.update(:address => "1.1.1.1", :port=>2000)
      @app.parse(["1.1.1.1:2000"]).should ==
        @defopts.update(:address => "1.1.1.1", :port=>2000)
    end
    
    it "should parse with the port, address, and protocol" do
      @app.parse(["http://1.1.1.1:2000"]).should ==
        @defopts.update(:address => "1.1.1.1", :port=>2000)
    end
    
    it "should parse help" do
      @app.parse([])[:help].should be_false
      @app.parse(["-h"])[:help].should be_true
      @app.parse(["--help"])[:help].should be_true
    end
    
    it "should parse version" do
      @app.parse([])[:version].should be_false
      @app.parse(["-v"])[:version].should be_true
      @app.parse(["--version"])[:version].should be_true
    end
    
    it "should parse environment" do
      @app.parse([])[:environment].should == "development"
      @app.parse(["production"])[:environment].should == "production"
      @app.parse(["test"])[:environment].should == "test"
      @app.parse(["development"])[:environment].should == "development"
    end
    
    it "should parse working directory" do
      @app.parse([])[:root].should == Dir.pwd
      dir = File.dirname(__FILE__)
      @app.parse([dir])[:root].should == File.expand_path(dir)
    end
    
    it "should parse ceate" do
      create = ['create', 'newapp', '/Users/user']
      @app.parse(create)[:create][:name].should == 'newapp'
      @app.parse(create)[:create][:directory].should == '/Users/user'
      @app.parse(create)[:create][:framework].should be_nil
    end
    
    it "should parse convert" do
      convert = ['convert', '/Users/user']
      @app.parse(convert)[:convert][:directory].should == '/Users/user'
      @app.parse(convert)[:convert][:framework].should be_nil
    end
    
    
    it "should parse create with a javascript framework" do
      create = ['create', 'newapp', '/Users/user', '-j', 'jquery']
      @app.parse(create)[:create][:name].should == 'newapp'
      @app.parse(create)[:create][:directory].should == '/Users/user'
      @app.parse(create)[:create][:framework].should == 'jquery'
    end
    
    it "should parse convert with a javascript framework" do
      convert = ['convert', '/Users/user', '--javascript', 'mootools']
      @app.parse(convert)[:convert][:directory].should == '/Users/user'
      @app.parse(convert)[:convert][:framework].should == 'mootools'
    end
    
    
    it "should detect invalid arguments" do
      lambda { @app.parse(["--invalid"]) }.should raise_error(Serve::Application::InvalidArgumentsError)
      lambda { @app.parse(["invalid"]) }.should raise_error(Serve::Application::InvalidArgumentsError)
    end
  end
  
  describe "running" do
    
  end
  
end