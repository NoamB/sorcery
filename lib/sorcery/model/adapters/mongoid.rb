module Sorcery
  module Model
    module Adapters
      module Mongoid
        def self.included(klass)
          klass.extend ClassMethods
          klass.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def increment(attr)
            self.inc(attr,1)
          end
        end

        module ClassMethods
          def find_by_credentials(credentials)
            where(sorcery_config.username_attribute_name => credentials[0]).first
          end

          def find_by_provider_and_uid(provider, uid)
            user_klass = ::Sorcery::Controller::Config.user_class
            where(user_klass.sorcery_config.provider_attribute_name => provider, user_klass.sorcery_config.provider_uid_attribute_name => uid).first
          end

          def find_by_id(id)
            find(id)
          end

          def find_by_activation_token(token)
            where(sorcery_config.activation_token_attribute_name => token).first
          end

          def find_by_remember_me_token(token)
            where(sorcery_config.remember_me_token_attribute_name => token).first
          end

          def find_by_username(username)
            where(sorcery_config.username_attribute_name => username).first
          end

          def transaction(&blk)
            tap(&blk)
          end

          def find_by_sorcery_token(token_attr_name, token)
            where(token_attr_name => token).first
          end

          def find_by_email(email)
            where(sorcery_config.email_attribute_name => email).first
          end

          def get_current_users
            config = sorcery_config
            where(config.last_activity_at_attribute_name.ne => nil) \
            .any_of({config.last_logout_at_attribute_name => nil},{config.last_activity_at_attribute_name.gt => config.last_logout_at_attribute_name}) \
            .and(config.last_activity_at_attribute_name.gt => config.activity_timeout.seconds.ago.utc.to_s(:db)).order_by([:_id,:asc])
          end
        end
      end
    end
  end
end
