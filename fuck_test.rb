require 'rubygems'

require 'fuck'

require 'rack/mock'
require 'stringio'

require 'test/spec'

### Sample Handler

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
    # TBD
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

context "Fuck" do
  
  specify "can route to list all of the resources" do
    status, headers, body = get("/posts")
    
    status.should == 200
    body.should =~ /Fuckin A!/
  end
  
  specify "can route to read the specific resource" do
    status, headers, body = get("/posts/1")
    
    status.should == 200
    body.should =~ /You asked for 1/
  end
  
  specify "can route to delete the specific resource" do
    status, headers, body = delete("/posts/1")
    
    status.should == 200
    body.should =~ /You asked me to delete 1/
  end
  
  specify "can route to create a new resource" do
    status, headers, body = put("/posts?a=b")
    
    status.should == 200
    body.should =~ /b/
  end
  
  specify "can route updates for a given resource" do
    status, headers, body = post("/posts/1?a=c")
    
    status.should == 200
    body.should =~ /c/
  end
  
end
