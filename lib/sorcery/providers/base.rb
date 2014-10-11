module Sorcery
  module Providers
    class Base

      attr_reader   :access_token

      attr_accessor :callback_url, :key, :original_callback_url, :secret,
                    :site, :state, :user_info_mapping, :user_hash

      def has_callback?; true; end

      def initialize
        @user_info_mapping = {}
      end

      def user_hash(access_token, hash={})
        if access_token
          hash.merge!({ token: access_token.token }) if access_token.respond_to?(:token)
          hash.merge!({ refresh_token: access_token.refresh_token }) if access_token.respond_to?(:refresh_token)
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
