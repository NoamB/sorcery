class User
  include Mongoid::Document

  field :username, type: String

  has_many :authentications, :dependent => :destroy
end
