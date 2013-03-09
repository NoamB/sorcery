class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :authentications_attributes, :username
  
  has_many :authentications, :dependent => :destroy
  has_many :access_tokens, :dependent => :delete_all
  accepts_nested_attributes_for :authentications
end
