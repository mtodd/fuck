require 'rack'

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
      send(find_method(env["REQUEST_METHOD"]) || :unrecognized, *[@id].compact)
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
    
    def unrecognized
      respond("Internal Server Error", :status => 500)
    end
    
  end
  
end
