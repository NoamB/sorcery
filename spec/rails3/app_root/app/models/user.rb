class User < ActiveRecord::Base
  activate_simple_auth!
  
  validates_uniqueness_of :username, :message => "must be unique"
  validates_uniqueness_of :email, :message => "must be unique"
end
