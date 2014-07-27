module Sorcery
  module Adapters
    class ActiveRecordAdapter < BaseAdapter
      def update_attributes(attrs)
        attrs.each do |name, value|
          @model.send(:"#{name}=", value)
        end
        primary_key = @model.class.primary_key
        @model.class.where(:"#{primary_key}" => @model.send(:"#{primary_key}")).update_all(attrs)
      end

      def save(options = {})
        mthd = options.delete(:raise_on_failure) ? :save! : :save
        @model.send(mthd, options)
      end

      def increment(field)
        @model.increment!(field)
      end

      def find_authentication_by_oauth_credentials(relation_name, provider, uid)
        @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
        conditions = {
          @user_config.provider_uid_attribute_name => uid,
          @user_config.provider_attribute_name     => provider
        }

        @model.public_send(relation_name).where(conditions).first
      end

      class << self
        def define_field(name, type, options={})
          # AR fields are defined through migrations, only validator here
        end

        def define_callback(time, event, method_name, options={})
          @klass.send "#{time}_#{event}", method_name, options.slice(:if)
        end

        def find_by_oauth_credentials(provider, uid)
          @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
          conditions = {
            @user_config.provider_uid_attribute_name => uid,
            @user_config.provider_attribute_name     => provider
          }

          @klass.where(conditions).first
        end

        def find_by_remember_me_token(token)
          @klass.where(@klass.sorcery_config.remember_me_token_attribute_name => token).first
        end

        def find_by_credentials(credentials)
          relation = nil

          @klass.sorcery_config.username_attribute_names.each do |attribute|
            if @klass.sorcery_config.downcase_username_before_authenticating
              condition = @klass.arel_table[attribute].lower.eq(@klass.arel_table.lower(credentials[0]))
            else
              condition = @klass.arel_table[attribute].eq(credentials[0])
            end

            if relation.nil?
              relation = condition
            else
              relation = relation.or(condition)
            end
          end

          @klass.where(relation).first
        end

        def find_by_token(token_attr_name, token)
          condition = @klass.arel_table[token_attr_name].eq(token)

          @klass.where(condition).first
        end

        def find_by_activation_token(token)
          @klass.where(@klass.sorcery_config.activation_token_attribute_name => token).first
        end

        def find_by_id(id)
          @klass.find_by_id(id)
        end

        def find_by_username(username)
          @klass.sorcery_config.username_attribute_names.each do |attribute|
            if @klass.sorcery_config.downcase_username_before_authenticating
              username = username.downcase
            end

            result = @klass.where(attribute => username).first
            return result if result
          end
        end

        def find_by_email(email)
          @klass.where(@klass.sorcery_config.email_attribute_name => email).first
        end

        def get_current_users
          config = @klass.sorcery_config

          @klass
            .where("#{config.last_activity_at_attribute_name} IS NOT NULL") \
            .where("#{config.last_logout_at_attribute_name} IS NULL OR #{config.last_activity_at_attribute_name} > #{config.last_logout_at_attribute_name}") \
            .where("#{config.last_activity_at_attribute_name} > ? ", config.activity_timeout.seconds.ago.utc.to_s(:db))
        end

        def transaction(&blk)
          @klass.tap(&blk)
        end
      end
    end


  end
end
