module Sorcery
  module Model
    module Adapters
      module ActiveRecord
        def self.included(klass)
          klass.extend ClassMethods
          klass.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def update_many_attributes(attrs)
            attrs.each do |name, value|
              self.send(:"#{name}=", value)
            end
            primary_key = self.class.primary_key
            self.class.where(:"#{primary_key}" => self.send(:"#{primary_key}")).update_all(attrs)
          end

          def update_single_attribute(name, value)
            update_many_attributes(name => value)
          end
        end
        
        module ClassMethods
          def column_name(attribute)
            return "LOWER(#{attribute})" if (@sorcery_config.downcase_username_before_authenticating)
            return "#{attribute}"
          end

          def find_by_credentials(credentials)
             sql = @sorcery_config.username_attribute_names.map{|attribute| column_name(attribute) + " = :login"}
             where(sql.join(' OR '), :login => credentials[0]).first
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
