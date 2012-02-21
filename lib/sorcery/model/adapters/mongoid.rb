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

          def update_single_attribute(name, value)
            value = value.utc if value.is_a?(ActiveSupport::TimeWithZone)
            self.send(:"#{name}=", value)
            self.class.where(:_id => self.id).update_all(name => value)
          end
        end

        module ClassMethods
          def find_by_credentials(credentials)
            credentials[0] = credentials[0].downcase if @sorcery_config.downcase_username_before_authenticating

            @sorcery_config.username_attribute_names.each do |attribute|
              if @sorcery_config.use_case_insensitive_matching.present?
                @user = where(attribute => {:$regex => /^#{credentials[0]}/i}).first
              else
                @user = where(attribute => credentials[0]).first
              end
              break if @user
            end
            @user
          end

          def find_by_provider_and_uid(provider, uid)
            @user_klass ||= ::Sorcery::Controller::Config.user_class.to_s.constantize
            where(@user_klass.sorcery_config.provider_attribute_name => provider, @user_klass.sorcery_config.provider_uid_attribute_name => uid).first
          end

          def find_by_id(id)
            find(id)
          rescue ::Mongoid::Errors::DocumentNotFound
            nil
          end

          def find_by_activation_token(token)
            where(sorcery_config.activation_token_attribute_name => token).first
          end

          def find_by_remember_me_token(token)
            where(sorcery_config.remember_me_token_attribute_name => token).first
          end

          def find_by_username(username)
            query = sorcery_config.username_attribute_names.map {|name| {name => username}}
            any_of(*query).first
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
            .where("this.#{config.last_logout_at_attribute_name} == null || this.#{config.last_activity_at_attribute_name} > this.#{config.last_logout_at_attribute_name}") \
            .and(config.last_activity_at_attribute_name.gt => config.activity_timeout.seconds.ago.utc.to_s(:db)).order_by([:_id,:asc])
          end
        end
      end
    end
  end
end
