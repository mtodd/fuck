class Fuck
  
  class Resource
    
    DEFAULT_HEADERS = {"Content-Type" => "text/html"}
    
    def initialize(id, params)
      @id, @params = id, params
    end
    
    def call(env)
      @env = env
      request_method = find_method(@env["REQUEST_METHOD"]) || :not_implemented
      return not_implemented unless self.respond_to?(request_method)
      send(request_method, *[@id].compact) or not_found
    rescue Exception => e
      @env['rack.errors'].puts "ERROR: %s" % e.message
      @env['rack.errors'].puts "\t%s" % e.backtrace.join("\n\t")
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
    
    def location_for(id)
      "%s://%s/%s" % [@env["rack.url_scheme"], @env["HTTP_HOST"], [self.class.to_s.downcase, id].join('/')]
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
