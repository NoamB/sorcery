require 'digest/md5'
require 'active_support'

module SimpleAuth
  module ORM
    extend ::ActiveSupport::Concern
    
    module ClassMethods
      def activate_simple_auth!
        yield Config if block_given?
        
        self.class_eval do
          def self.authentic?(username, password)
            where("#{Config.username_attribute_name} = ? AND #{Config.crypted_password_attribute_name} = ?", username, Digest::MD5.hexdigest(password)).first
          end
        end
      end
    end
    
    module Config
      class << self
        attr_accessor :username_attribute_name, 
                      :crypted_password_attribute_name,
                      :encryption_algorithm
      
        def reset_to_defaults!
          @username_attribute_name         = :username
          @crypted_password_attribute_name = :crypted_password
          @encryption_algorithm            = :md5
        end
      
      end
      reset_to_defaults!
    end
  end
end