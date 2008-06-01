require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Serve" do
  
  it "should register all of the file type handlers" do
    handlers = ["cgi", "email", "erb", "haml", "html.erb", "html.haml", "markdown", "redirect", "rhtml", "sass", "textile"]
    table = WEBrick::HTTPServlet::FileHandler::HandlerTable
    table.keys.sort.should == handlers
  end
  
end