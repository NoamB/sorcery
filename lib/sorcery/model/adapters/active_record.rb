module Sorcery
  module Model
    module Adapters
      module ActiveRecord
        def self.included(klass)
          klass.extend ClassMethods
        end

        module ClassMethods
          def find_by_credentials(credentials)
            @sorcery_config.username_attribute_name.each do |attribute|
              @user = where("#{attribute} = ?", credentials[0]).first
              break if @user
            end
            @user
          end

          def find_by_sorcery_token(token_attr_name, token)
            where("#{token_attr_name} = ?", token).first
          end

          def get_current_users
            config = sorcery_config
            where("#{config.last_activity_at_attribute_name} IS NOT NULL") \
            .where("#{config.last_logout_at_attribute_name} IS NULL OR #{config.last_activity_at_attribute_name} > #{config.last_logout_at_attribute_name}") \
            .where("#{config.last_activity_at_attribute_name} > ? ", config.activity_timeout.seconds.ago.utc.to_s(:db))
          end
        end
      end
    end
  end
end
