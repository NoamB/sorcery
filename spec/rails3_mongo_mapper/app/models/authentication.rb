class Authentication
  include MongoMapper::Document
  key :provider, String
  key :uid, Integer
  belongs_to :user
end