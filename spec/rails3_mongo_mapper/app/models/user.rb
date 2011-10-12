class User
  include MongoMapper::Document

  has_many :authentications, :dependent => :destroy
end
