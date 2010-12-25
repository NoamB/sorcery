module SimpleAuth
  module ORM
    extend ActiveSupport::Concern
    
    module ClassMethods
      def activate_simple_auth!
        yield Config if block_given?
        
        self.class_eval do
          def self.authentic?(username, password)

          end
        end
      end
    end
    
    module Config
      mattr_accessor :username_attribute_name
      
      @@username_attribute_name = :username
    end
  end
end