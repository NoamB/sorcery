class User < ActiveRecord::Base
  has_many :authentications, :dependent => :destroy
  has_many :user_providers, :dependent => :destroy
  accepts_nested_attributes_for :authentications
end
