class User
  include Mongoid::Document

  field :username, type: String
  field :locked, type: Boolean

  has_many :authentications, :dependent => :destroy
end
