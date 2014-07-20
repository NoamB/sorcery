module Sorcery
  module Adapters
    class MongoidAdapter < BaseAdapter
      def increment(attr)
        mongoid_4? ? @model.inc(attr => 1) : @model.inc(attr, 1)
      end

      def update_attributes(attrs)
        attrs.each do |name, value|
          attrs[name] = value.utc if value.is_a?(ActiveSupport::TimeWithZone)
          @model.send(:"#{name}=", value)
        end
        @model.class.where(:_id => @model.id).update_all(attrs)
      end

      def update_attribute(name, value)
        update_attributes(name => value)
      end

      def save(options = {})
        mthd = options.delete(:raise_on_failure) ? :save! : :save
        @model.send(mthd, options)
      end

      def mongoid_4?
        Gem::Version.new(::Mongoid::VERSION) >= Gem::Version.new("4.0.0.alpha")
      end

      class << self

        def define_field(name, type, options={})
          @klass.field name, options.slice(:default).merge(type: type)
        end

        def define_callback(time, event, method_name, options={})
          @klass.send "#{time}_#{event}", method_name, options.slice(:if)
        end

        def credential_regex(credential)
          return { :$regex =>  /^#{Regexp.escape(credential)}$/i  } if (@klass.sorcery_config.downcase_username_before_authenticating)
          credential
        end

        def find_by_credentials(credentials)
          @klass.sorcery_config.username_attribute_names.each do |attribute|
            @user = @klass.where(attribute => credential_regex(credentials[0])).first
            break if @user
          end
          @user
        end

        def find_by_oauth_credentials(provider, uid)
          @user_config ||= ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
          @klass.where(@user_config.provider_attribute_name => provider, @user_config.provider_uid_attribute_name => uid).first
        end

        def find_by_activation_token(token)
          @klass.where(@klass.sorcery_config.activation_token_attribute_name => token).first
        end

        def find_by_remember_me_token(token)
          @klass.where(@klass.sorcery_config.remember_me_token_attribute_name => token).first
        end

        def transaction(&blk)
          tap(&blk)
        end

        def find_by_id(id)
          @klass.find(id)
        rescue ::Mongoid::Errors::DocumentNotFound
          nil
        end

        def find_by_username(username)
          query = @klass.sorcery_config.username_attribute_names.map {|name| {name => username}}
          @klass.any_of(*query).first
        end

        def find_by_token(token_attr_name, token)
          @klass.where(token_attr_name => token).first
        end

        def find_by_email(email)
          @klass.where(@klass.sorcery_config.email_attribute_name => email).first
        end

        def get_current_users
          config = @klass.sorcery_config
          @klass.where(config.last_activity_at_attribute_name.ne => nil) \
          .where("this.#{config.last_logout_at_attribute_name} == null || this.#{config.last_activity_at_attribute_name} > this.#{config.last_logout_at_attribute_name}") \
          .where(config.last_activity_at_attribute_name.gt => config.activity_timeout.seconds.ago.utc).order_by([:_id,:asc])
        end
      end
    end
  end
end
