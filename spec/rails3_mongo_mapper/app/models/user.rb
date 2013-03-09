class User
  include MongoMapper::Document

  many :authentications, :dependent => :destroy
  many :access_tokens, :dependent => :delete_all
end
