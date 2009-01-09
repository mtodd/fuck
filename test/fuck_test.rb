require 'rubygems'

require File.join(File.dirname(__FILE__), '..', 'lib', 'fuck')

require 'rack/mock'
require 'stringio'

require 'test/spec'

### Sample Handlers

class Posts < Fuck::Resource
  def all
    respond "Fuckin A!"
  end
  def create
    respond params["a"]
  end
  def read(id)
    respond "You asked for #{id}?"
  end
  def update(id)
    respond params["a"]
  end
  def delete(id)
    respond "You asked me to delete #{id}"
  end
end

class Exceptions < Fuck::Resource
  def all
    raise "An error in the app"
  end
  # def create
  #   # make it not exist
  # end
  def read(id)
    # do not respond with anything
  end
  def update(id)
    [200, {"Content-Type"=>"text/html"}, "OK"]
  end
  def delete(id)
    not_found
  end
end

### Tests

def request(path, options = {})
  Fuck.call(Rack::MockRequest.env_for(path, options))
end
def get(path, options = {}) request(path, options.merge({"REQUEST_METHOD" => "GET"})) end
def post(path, options = {}) request(path, options.merge({"REQUEST_METHOD" => "POST"})) end
def put(path, options = {}) request(path, options.merge({"REQUEST_METHOD" => "PUT"})) end
def delete(path, options = {}) request(path, options.merge({"REQUEST_METHOD" => "DELETE"})) end

context "Fuck can route" do
  
  specify "to list all of the resources" do
    status, headers, body = get("/posts")
    
    status.should == 200
    body.should =~ /Fuckin A!/
  end
  
  specify "to read the specific resource" do
    status, headers, body = get("/posts/1")
    
    status.should == 200
    body.should =~ /You asked for 1/
  end
  
  specify "to delete the specific resource" do
    status, headers, body = delete("/posts/1")
    
    status.should == 200
    body.should =~ /You asked me to delete 1/
  end
  
  specify "to create a new resource" do
    status, headers, body = put("/posts?a=b")
    
    status.should == 200
    body.should =~ /b/
  end
  
  specify "updates for a given resource" do
    status, headers, body = post("/posts/1?a=c")
    
    status.should == 200
    body.should =~ /c/
  end
  
end

context "Fuck can fuck up" do
  
  specify "responds with an 500 Internal Server Error if an exception occurs" do
    status, headers, body = get("/exceptions")
    
    status.should == 500
    body.should == "Internal Server Error"
  end
  
  specify "responds with a 501 Not Implemented if no method was implemented" do
    status, headers, body = put("/exceptions/1")
    
    status.should == 501
    body.should == "Not Implemented"
  end
  
  specify "returns 404 Not Found if no response is given" do
    status, headers, body = get("/exceptions/1")
    
    status.should == 404
    body.should == "Not Found"
  end
  
  specify "can manually respond with the Rack specified response" do
    status, headers, body = post("/exceptions/1")
    
    status.should == 200
    body.should == "OK"
  end
  
  specify "can respond that no record was found" do
    status, headers, body = delete("/exceptions/1")
    
    status.should == 404
    body.should == "Not Found"
  end
  
end
