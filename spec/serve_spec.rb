require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Serve" do
  
  it "should register all of the file type handlers" do
    handlers = ["cgi", "email", "haml", "markdown", "redirect", "rhtml", "sass", "textile"]
    table = WEBrick::HTTPServlet::FileHandler::HandlerTable
    table.keys.sort.should == handlers
  end
  
end