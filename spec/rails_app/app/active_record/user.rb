class User < ActiveRecord::Base
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications
end
