module Sorcery
  module Providers
    class Base

      attr_reader   :access_token

      attr_accessor :callback_url, :key, :original_callback_url, :secret,
                    :site, :state, :user_info_mapping

      def has_callback?; true; end

      def initialize
        @user_info_mapping = {}
      end

      def auth_hash(access_token, hash={})
        if access_token
          hash[:token] = access_token.token if access_token.respond_to?(:token)
          hash[:refresh_token] = access_token.refresh_token if access_token.respond_to?(:refresh_token)
          hash[:expires_at] = access_token.expires_at if access_token.respond_to?(:expires_at)
          hash[:expires_in] = access_token.expires_at if access_token.respond_to?(:expires_in)
        end
        hash
      end

      def self.name
        super.gsub(/Sorcery::Providers::/, '').downcase
      end

      # Ensure that all descendant classes are loaded before run this
      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

    end
  end
end
