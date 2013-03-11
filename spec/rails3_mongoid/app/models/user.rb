class User
  include Mongoid::Document

  has_many :authentications, :dependent => :destroy
  has_many :access_tokens, :dependent => :delete_all
end
