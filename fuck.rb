require 'rack'

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
  class << self
    
    PATH_INFO = %r{/?(\w+)(/(\w+))?}
    
    def call(env)
      find_handler(env["PATH_INFO"], env["QUERY_STRING"]).call(env)
    end
    
    def find_handler(path_info, query_string)
      path_info =~ PATH_INFO
      resource, _, id = $1, $2, $3
      params = Rack::Utils.parse_query(query_string)
      Object.const_get(resource.capitalize).new(id, params)
    end
    
  end
  
  class Resource
    
    DEFAULT_HEADERS = {"Content-Type" => "text/html"}
    
    def initialize(id, params)
      @id, @params = id, params
    end
    
    def call(env)
      send((find_method(env["REQUEST_METHOD"]) || :not_implemented), *[@id].compact) or
      not_found
    rescue NoMethodError => e
      not_implemented
    rescue Exception => e
      # logger.error e.message
      # logger.error "\t"+e.backtrace.join("\n\t")
      respond("Internal Server Error", :status => 500)
    end
    
    def find_method(request_method)
      case request_method
      when "GET"
        if @id.nil?
          :all
        else
          :read
        end
      when "PUT"
        :create
      when "POST"
        :update unless @id.nil?
      when "DELETE"
        :delete unless @id.nil?
      else
        nil
      end
    end
    
    def params
      @params
    end
    
    def respond(body = "OK", options = {}, headers = {})
      options = {:status => 200}.merge(options)
      [
        options[:status],
        DEFAULT_HEADERS.merge({
          "Content-Length" => body.size.to_s
        }.merge(headers)),
        body
      ]
    end
    
    def not_found
      respond("Not Found", :status => 404)
    end
    
    def not_implemented
      respond("Not Implemented", :status => 501)
    end
    
  end
  
end
