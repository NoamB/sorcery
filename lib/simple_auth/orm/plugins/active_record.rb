module SimpleAuth
  module ORM
    module Plugins
      module ActiveRecord
        def self.included(klass)
          klass.class_eval do
            attr_accessor Config.password_attribute_name
            attr_accessor Config.password_confirmation_attribute_name if Config.confirm_password

            validate :password_confirmed if Config.confirm_password
            before_save :encrypt_password

            def encrypt_password
              self.send("#{Config.crypted_password_attribute_name}=".to_sym, self.class.encrypt(self.send(Config.password_attribute_name))) if self.new_record? || self.password
            end

            def password_confirmed
              if self.send(Config.password_attribute_name) && self.send(Config.password_attribute_name) != self.send(Config.password_confirmation_attribute_name)
                self.errors.add(:base,"password and password_confirmation do not match!")
              end
            end
          end
        end
      end
    end
  end
end