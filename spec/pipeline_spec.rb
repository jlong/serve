require File.dirname(__FILE__) + '/spec_helper.rb'
require 'serve/pipeline'

describe Serve::Pipeline do
  before :each do
    @root = File.expand_path("../fixtures", __FILE__)
  end
  
  describe "self.handles?" do
    it "should not handle .html" do
      Serve::Pipeline.handles?("dir/file.html").should be_false
    end

    it "should handle .markdown" do
      Serve::Pipeline.handles?("dir/file.markdown").should be_true
    end

    it "should handle .html.markdown" do
      Serve::Pipeline.handles?("dir/file.html.markdown").should be_true
    end

    it "should handle .coffee" do
      Serve::Pipeline.handles?("dir/file.coffee").should be_true
    end

    it "should handle .markdown.erb" do
      Serve::Pipeline.handles?("dir/file.markdown.erb").should be_true
    end
  end

  describe "initialize" do
    it "should build a pipeline for .markdown" do
      pipeline = Serve::Pipeline.new(@root, "directory/markdown.markdown")
      pipeline.template.handlers.collect{|h| h.extension}.should == %w(markdown)
    end

    it "should build a pipeline for .html.markdown" do
      pipeline = Serve::Pipeline.new(@root, "directory/markdown.html.markdown")
      pipeline.template.handlers.collect{|h| h.extension}.should == %w(markdown)
    end

    it "should build a pipeline for .coffee" do
      pipeline = Serve::Pipeline.new(@root, "directory/coffee.coffee")
      pipeline.template.handlers.collect{|h| h.extension}.should == %w(coffee)
    end

    it "should build a pipeline for .markdown.erb" do
      pipeline = Serve::Pipeline.new(@root, "directory/markdown_erb.markdown.erb")
      pipeline.template.handlers.collect{|h| h.extension}.should == %w(markdown erb)
    end
  end
end