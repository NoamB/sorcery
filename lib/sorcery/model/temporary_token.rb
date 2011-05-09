module Sorcery
  module Model
    # This module encapsulates the logic for temporary token.
    # A temporary token is created to identify a user in scenarios such as reseting password and activating the user by email.
    module TemporaryToken
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def load_from_token(token, token_attr_name, token_expiration_date_attr)
          return nil if token.blank?
          user = find_by_token(token_attr_name,token)
          if !user.blank? && !user.send(token_expiration_date_attr).nil?
            return Time.now.utc < user.send(token_expiration_date_attr) ? user : nil
          end
          user
        end
      end
    end
  end
end
