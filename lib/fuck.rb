require 'rack'

$:.unshift(File.expand_path(File.dirname(__FILE__)))

# Fuck is a fuckin' framework.
# 
# It's:
# * kinda fucking retarded
# * hastily done
# * rather pointless
# * far from thorough or done
# 
# Fuck::Resource apps are able to be recognized and called on. The class name
# will match up to the request, and the action is determined by the request
# method.
# 
# There is a middleware for emulating the proper request method if you're using
# forms and are not able to properly PUT and DELETE.
# 
# The ID is what trails the resource's name, by a slash.
# 
# To illustrate:
#   GET     /posts    => Posts#all
#   POST    /posts    => Posts#create
#   GET     /posts/1  => Posts#read(id)
#   PUT     /posts/1  => Posts#update(id)
#   DELETE  /posts/1  => Posts#delete(id)
# 
# Usage:
# 
#   class Posts < Fuck::Resource
#     
#     # GET /posts
#     def all
#       respond("OK", :status => 200)
#     end
#     
#     # POST /posts/1
#     def create(id)
#       respond("OK", :status => 200)
#     end
#     
#     # GET /posts/1
#     def read(id)
#       respond("OK", :status => 200)
#     end
#     
#     # PUT /posts/1
#     def update(id)
#       respond("OK", :status => 200)
#     end
#     
#     # DELETE /posts/1
#     def delete(id)
#       respond("OK", :status => 200)
#     end
#     
#   end
# 
# Obviously, you'll want to do a little bit of work with actually getting the
# contents of an object and displaying it correctly. This is left (for now)
# entirely up to you.
# 
class Fuck
  
  VERSION = [0,1,1]
  
  class << self
    
    PATH_INFO = %r{/?(\w+)(/(\w+))?}
    
    def call(env)
      if handler = find_handler(env["PATH_INFO"], env["QUERY_STRING"])
        handler.call(env)
      else
        [404, {'Content-Type' => 'text/html'}, []]
      end
    rescue Exception => e
      env['rack.errors'].puts "ERROR: %s" % e.message
      env['rack.errors'].puts "\t%s" % e.backtrace.join("\n\t")
      [500, {'Content-Type' => 'text/html'}, []]
    end
    
    def find_handler(path_info, query_string)
      if path_info =~ PATH_INFO
        resource, _, id = $1, $2, $3
        params = Rack::Utils.parse_query(query_string)
        Object.const_get(resource.capitalize).new(id, params)
      else
        nil
      end
    end
    
  end
  
  autoload :Resource, "fuck/resource"
  
end
