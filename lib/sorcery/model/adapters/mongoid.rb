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
            where(@sorcery_config.username_attribute_name => credentials[0]).first
          end

          def find_by_provider_and_uid(provider, uid)
            where(:provider => provider, :uid => uid).first
          end

          def find_by_id(id)
            find(id)
          end

          def find_by_activation_token(token)
            where(:activation_token => token).first
          end

          def find_by_remember_me_token(token)
            where(:remember_me_token => token).first
          end

          def find_by_username(username)
            where(:username => username).first
          end

          def transaction(&blk)
            tap(&blk)
          end

          def find_by_token(token_attr_name, token)
            where(token_attr_name => token).first
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