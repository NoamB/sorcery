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
