module Sorcery
  module Model
    module Adapters
      module MongoMapper
        extend ActiveSupport::Concern

        included do
          extend Sorcery::Model
        end

        def increment(attr)
          self.class.increment(id, attr => 1)
        end

        def sorcery_save(options = {})
          if options.delete(:raise_on_failure) && options[:validate] != false
            save! options
          else
            save options
          end
        end

        def update_many_attributes(attrs)
          update_attributes(attrs)
        end

        module ClassMethods
          def define_field(name, type, options={})
            key name, type, options.slice(:default)
          end

          def credential_regex(credential)
            return { :$regex =>  /^#{Regexp.escape(credential)}$/i  }  if (@sorcery_config.downcase_username_before_authenticating)
            return credential
          end

          def find_by_credentials(credentials)
            @sorcery_config.username_attribute_names.each do |attribute|
              @user = where(attribute => credential_regex(credentials[0])).first
              break if @user
            end
            @user
          end

          def find_by_oauth_credentials(provider, uid)
            @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
            where(@user_config.provider_attribute_name => provider, @user_config.provider_uid_attribute_name => uid).first
          end

          def find_by_id(id)
            find(id)
          end

          def find_by_activation_token(token)
            where(sorcery_config.activation_token_attribute_name => token).first
          end

          def transaction(&blk)
            tap(&blk)
          end

          def find_by_sorcery_token(token_attr_name, token)
            where(token_attr_name => token).first
          end
        end
      end
    end
  end
end
