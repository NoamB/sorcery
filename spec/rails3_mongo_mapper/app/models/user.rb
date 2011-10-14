class User
  include MongoMapper::Document

  many :authentications, :dependent => :destroy
end
