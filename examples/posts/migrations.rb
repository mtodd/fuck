require 'rubygems'
require 'activerecord'

ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3", 
  :dbfile => "db/development.db"
})

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.string :body
      t.string :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end

# run the migrations
CreateUsers.migrate(:up)
CreatePosts.migrate(:up)

