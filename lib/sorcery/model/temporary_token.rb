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
        def load_from_token(token, token_attr_name, token_expiration_date_attr = nil, &block)
          if token.blank?
            return token_response(failure: :invalid_token, &block)
          end

          user = sorcery_adapter.find_by_token(token_attr_name, token)

          unless user
            return token_response(failure: :user_not_found, &block)
          end

          # if !user.blank? && !user.send(token_expiration_date_attr).nil?
          #   return Time.now.in_time_zone < user.send(token_expiration_date_attr) ? user : nil
          # end

          unless check_expiration_date(user, token_expiration_date_attr)
            return token_response(user: user, failure: :token_expired, return_value: nil, &block)
          end

          token_response(user: user, return_value: user, &block)
        end

        protected

        def check_expiration_date(user, token_expiration_date_attr)
          return true unless token_expiration_date_attr

          expires_at = user.send(token_expiration_date_attr)

          return true unless expires_at

          Time.now.in_time_zone < expires_at
        end

        def token_response(options = {}, &block)
          block.call(options[:user], options[:failure]) if block_given?

          options[:return_value]
        end
      end
    end
  end
end
