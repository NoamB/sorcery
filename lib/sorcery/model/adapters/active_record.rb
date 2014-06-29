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

          def sorcery_save(options = {})
            mthd = options.delete(:raise_on_failure) ? :save! : :save
            self.send(mthd, options)
          end
        end

        module ClassMethods
          def define_sorcery_field(name, type, options={})
            # AR fields are defined through migrations, only validator here
          end

          def define_sorcery_callback(time, event, method_name, options={})
            send "#{time}_#{event}", method_name, options.slice(:if)
          end

          def find_by_oauth_credentials(provider, uid)
            @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
            conditions = {
              @user_config.provider_uid_attribute_name => uid,
              @user_config.provider_attribute_name     => provider
            }

            where(conditions).first
          end

          def find_by_credentials(credentials)
            relation = nil

            @sorcery_config.username_attribute_names.each do |attribute|
              if @sorcery_config.downcase_username_before_authenticating
                condition = arel_table[attribute].lower.eq(arel_table.lower(credentials[0]))
              else
                condition = arel_table[attribute].eq(credentials[0])
              end

              if relation.nil?
                relation = condition
              else
                relation = relation.or(condition)
              end
            end

            where(relation).first
          end

          def find_by_sorcery_token(token_attr_name, token)
            condition = arel_table[token_attr_name].eq(token)

            where(condition).first
          end

          def get_current_users
            config = @sorcery_config
            where("#{config.last_activity_at_attribute_name} IS NOT NULL") \
            .where("#{config.last_logout_at_attribute_name} IS NULL OR #{config.last_activity_at_attribute_name} > #{config.last_logout_at_attribute_name}") \
            .where("#{config.last_activity_at_attribute_name} > ? ", config.activity_timeout.seconds.ago.utc.to_s(:db))
          end
        end
      end
    end
  end
end
