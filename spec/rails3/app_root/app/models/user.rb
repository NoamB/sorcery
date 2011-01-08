class User < ActiveRecord::Base
  activate_simple_auth! :password_encryption
  
  validates_uniqueness_of :username, :message => "must be unique"
  validates_uniqueness_of :email, :message => "must be unique"
end
