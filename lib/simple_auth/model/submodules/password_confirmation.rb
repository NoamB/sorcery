module SimpleAuth
  module Model
    module Submodules
      module PasswordConfirmation
        def self.included(klass)
          Config.class_eval do
            class << self
              attr_accessor :password_confirmation_attribute_name
              
              DEFAULT_VALUES.merge!(:@password_confirmation_attribute_name => :password_confirmation)
            end
            reset!
          end
        end
      end
    end
  end
end