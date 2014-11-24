module Sorcery
  module Adapters
    class MongoMapperAdapter < BaseAdapter
      module Wrapper
        extend ActiveSupport::Concern

        included do
          extend Sorcery::Model
        end

        def sorcery_adapter
          @sorcery_adapter ||= Sorcery::Adapters::MongoMapperAdapter.new(self)
        end

        module ClassMethods
          def sorcery_adapter
            Sorcery::Adapters::MongoMapperAdapter.from(self)
          end
        end
      end

      def increment(attr)
        @model[attr] ||= 0
        @model[attr] += 1
        @model.class.increment(@model.id, attr => 1)
      end

      def save(options = {})
        if options.delete(:raise_on_failure) && options[:validate] != false
          @model.save! options
        else
          @model.save options
        end
      end

      def update_attributes(attrs)
        @model.update_attributes(attrs)
      end

      class << self
        def define_field(name, type, options={})
          @klass.key name, type, options.slice(:default)
        end

        def define_callback(time, event, method_name, options={})
          @klass.send "#{time}_#{event}", method_name, options.slice(:if)
        end

        def credential_regex(credential)
          return { :$regex =>  /^#{Regexp.escape(credential)}$/i } if (@klass.sorcery_config.downcase_username_before_authenticating)
          return credential
        end

        def find_by_credentials(credentials)
          user = nil
          @klass.sorcery_config.username_attribute_names.each do |attribute|
            user = @klass.where(attribute => credential_regex(credentials[0])).first
            break if user
          end
          user
        end

        def find_by_oauth_credentials(provider, uid)
          @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
          @klass.where(@user_config.provider_attribute_name => provider, @user_config.provider_uid_attribute_name => uid).first
        end

        def find_by_id(id)
          @klass.find(id)
        end

        def find_by_username(username)
          if @klass.sorcery_config.downcase_username_before_authenticating
            username = username.downcase
          end

          @klass.sorcery_config.username_attribute_names.each do |attribute|
            result = @klass.where(attribute => username).first
            return result if result
          end
        end

        def find_by_activation_token(token)
          @klass.where(@klass.sorcery_config.activation_token_attribute_name => token).first
        end

        def find_by_email(email)
          @klass.where(@klass.sorcery_config.email_attribute_name => email).first
        end

        def find_by_token(token_attr_name, token)
          @klass.where(token_attr_name => token).first
        end

        def transaction(&blk)
          @klass.tap(&blk)
        end

        def find_by_sorcery_token(token_attr_name, token)
          @klass.where(token_attr_name => token).first
        end

        def get_current_users
          raise "this method is unavailable for MongoMapper"
        end

      end
    end
  end
end
