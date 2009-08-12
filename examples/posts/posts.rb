require 'rubygems'
require 'activerecord'
require 'json'

ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3", 
  :dbfile => "db/development.db"
})

class Post < ActiveRecord::Base
  
  def to_json
    self.attributes.to_json
  end
  
end

class Posts < Fuck::Resource
  
  def all
    respond Post.find(:all).to_json
  end
  
  def create
    if post = Post.create(params)
      respond [], {:status => 201}, 'Location' => location_for(post.id)
    else
      respond "Unprocessable Entity", :status => 422
    end
  end
  
  def read(id)
    respond Post.find(id).to_json
  end
  
  def update(id)
    post = Post.find(id)
    if post.update_attributes(params)
      respond # OK
    else
      respond "Unprocessable Entity", :status => 422
    end
  end
  
  def delete(id)
    post = Post.find(id)
    if post.destroy
      respond
    else
      respond "Internal Server Error", :status => 500
    end
  end
  
end
