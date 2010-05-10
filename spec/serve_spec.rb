require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Serve" do
  
  it "should register all of the file type handlers" do
    Serve::WEBrick::Server.register_handlers
    handlers = ["cgi", "email", "erb", "haml", "html.erb", "html.haml", "markdown", "redirect", "rhtml", "sass", "scss", "textile"]
    table = WEBrick::HTTPServlet::FileHandler::HandlerTable
    table.keys.sort.should == handlers
  end
  
end