class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :authentications_attributes
  
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications
end
