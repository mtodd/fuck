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

### Tests

context "Fuck" do
  
  specify "can route to list all of the resources" do
    env = Rack::MockRequest.env_for("/posts")
    status, headers, body = Fuck.call(env)
    
    status.should == 200
    body.should =~ /Fuckin A!/
  end
  
  specify "can route to read the specific resource" do
    env = Rack::MockRequest.env_for("/posts/1")
    status, headers, body = Fuck.call(env)
    
    status.should == 200
    body.should =~ /You asked for 1/
  end
  
  specify "can route to delete the specific resource" do
    env = Rack::MockRequest.env_for("/posts/1", "REQUEST_METHOD" => "DELETE")
    status, headers, body = Fuck.call(env)
    
    status.should == 200
    body.should =~ /You asked me to delete 1/
  end
  
  specify "can route to create a new resource" do
    env = Rack::MockRequest.env_for("/posts?a=b", "REQUEST_METHOD" => "PUT")
    status, headers, body = Fuck.call(env)
    
    status.should == 200
    body.should =~ /b/
  end
  
  specify "can route updates for a given resource" do
    env = Rack::MockRequest.env_for("/posts/1?a=c", "REQUEST_METHOD" => "POST")
    status, headers, body = Fuck.call(env)
    
    status.should == 200
    body.should =~ /c/
  end
  
end
