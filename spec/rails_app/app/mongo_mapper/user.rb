class User
  include MongoMapper::Document

  key :username

  many :authentications, :dependent => :destroy
end
