require File.dirname(__FILE__) + '/spec_helper.rb'

describe Serve::Application do
  
  before :each do
    @app = Serve::Application.new
    @defopts = {
      :help => false,
      :help => false,
      :version => false,
      :environment => 'development',
      :port => nil,
      :address => '0.0.0.0',
      :document_root => Dir.pwd
    }
  end
  
  describe "parsing" do
    it "should parse no arguments" do
      @app.parse([]).should == @defopts
    end
    
    it "should parse with only the port" do
      @app.parse(["2000"])[:port].should == "2000"
    end
    
    it "should parse with the port and address" do
      @app.parse(["1.1.1.1", "2000"]).should ==
        @defopts.update(:address => "1.1.1.1", :port=>"2000")
      @app.parse(["1.1.1.1:2000"]).should ==
        @defopts.update(:address => "1.1.1.1", :port=>"2000")
    end
    
    it "should parse with the port, address, and protocol" do
      @app.parse(["http://1.1.1.1:2000"]).should ==
        @defopts.update(:address => "1.1.1.1", :port=>"2000")
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
      @app.parse([])[:document_root].should == Dir.pwd
      dir = File.dirname(__FILE__)
      @app.parse([dir])[:document_root].should == dir
    end
    
    it "should detect invalid arguments" do
      lambda { @app.parse(["--invalid"]) }.should raise_error(Serve::Application::InvalidArgumentsError)
      lambda { @app.parse(["invalid"]) }.should raise_error(Serve::Application::InvalidArgumentsError)
    end
  end
  
  describe "running" do
    
  end
  
end