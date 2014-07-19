require 'securerandom'

module Sorcery
  module Model
    # This module encapsulates the logic for temporary token.
    # A temporary token is created to identify a user in scenarios
    # such as reseting password and activating the user by email.
    module TemporaryToken
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Random code, used for salt and temporary tokens.
      def self.generate_random_token
        SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      end

      module ClassMethods
        def load_from_token(token, token_attr_name, token_expiration_date_attr)
          return nil if token.blank?
          user = sorcery_adapter.find_by_token(token_attr_name,token)
          if !user.blank? && !user.send(token_expiration_date_attr).nil?
            return Time.now.in_time_zone < user.send(token_expiration_date_attr) ? user : nil
          end
          user
        end
      end
    end
  end
end
