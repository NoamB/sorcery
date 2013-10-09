class User
  include Mongoid::Document

  has_many :authentications, :dependent => :destroy
end
