#class AccessToken < ActiveRecord::Base
class AccessToken
  include Mongoid::Document
  include Mongoid::Timestamps
  field :user_id, :type => Integer
  field :token, :type => String
  field :expirable, :type => Boolean, :default => true
  field :last_activity_at, :type => Time

  belongs_to :user
  validates :user_id, :presence => true

  before_create :generate_token, :update_last_activity_time

  #
  # Class methods
  #

  # Class method to delete expired access tokens, it can receive an optional
  # 'user_id' parameter to apply the deletion only to the given user.
  def self.delete_expired(user_id = nil)
    tokens = self.scoped rescue self # <- mongo_mapper does not have anonymous scope
    if self.sorcery_config.access_token_duration
      due_date = Time.zone.now - self.sorcery_config.access_token_duration.to_i
      tokens   = tokens.with_user_id(user_id) if user_id

      if self.sorcery_config.access_token_duration_from_last_activity
        tokens = tokens.with_last_activity_at_less_than(due_date)
      else
        tokens = tokens.with_created_at_less_than(due_date)
      end

      tokens = tokens.with_expirable(true)

      if ! tokens.empty?
        if defined?(MongoMapper) && self.ancestors.include?(MongoMapper::Document)
          tokens.each {|t| t.delete } # ...
        else
          tokens.delete_all
        end
      end
    end
  end

  # Expose sorcery config (User model)
  def self.sorcery_config
    User.sorcery_config
  end

  ##
  # Finders
  #

  def self.find_token(token)
    self.query_adapter(:token, '=', token).first
  end

  ##
  # Scopes
  #

  def self.with_user_id(user_id)
    self.query_adapter(:user_id, '=', user_id)
  end

  def self.with_last_activity_at_less_than(due_date)
    self.query_adapter(:last_activity_at, '<', due_date)
  end

  def self.with_created_at_less_than(due_date)
    self.query_adapter(:created_at, '<', due_date)
  end

  def self.with_expirable(bool)
    self.query_adapter(:expirable, '=', bool)
  end

  # Auxiliary class method, query adapter
  def self.query_adapter(attr, comparison_operator, value)
    if (defined?(Mongoid) && self.ancestors.include?(Mongoid::Document)) ||
       (defined?(MongoMapper) && self.ancestors.include?(MongoMapper::Document))

       case comparison_operator
       when '='
         self.where(attr => value)
       when '<'
         self.where(attr.lt => value)
       else
         nil
       end

    else
      case comparison_operator
      when '='
        self.where(attr => value)
      when '<'
        self.where("#{attr.to_s} < ?", value)
      else
        nil
      end
    end
  end

  #
  # Instance methods
  #

  # Overwrite ActiveRecord valid? method to support auth context,
  # returns true if token is valid for authentication.
  def valid?(context = nil)
    if context == :auth
      ! expired?
    else
      super(context)
    end
  end

  # Returns true if token has expired
  def expired?
    if self.expirable && sorcery_config.access_token_duration
      due_date = Time.zone.now - sorcery_config.access_token_duration.to_i
      if sorcery_config.access_token_duration_from_last_activity
        self.last_activity_at < due_date
      else
        self.created_at < due_date
      end
    else
      false
    end
  end

  def sorcery_config
    self.class.sorcery_config
  end

  def update_last_activity_time
    self.last_activity_at = Time.zone.now
  end

  private

    # Generate random token
    def generate_token
      begin
        self.token = TemporaryToken.generate_random_token
      end while self.class.find_token(self.token)
    end

end
