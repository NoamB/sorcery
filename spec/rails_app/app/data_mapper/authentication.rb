class Authentication
  include DataMapper::Resource

  property :id, Serial
  property :uid, Integer
  property :provider, String
  belongs_to :user
end
