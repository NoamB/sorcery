module Sorcery
  module Adapters
    class DataMapperAdapter < BaseAdapter
      module Wrapper
        extend ActiveSupport::Concern

        included do
          sorcery_adapter.verify_submodules_compatibility!
        end

        def sorcery_adapter
          @sorcery_adapter ||= Sorcery::Adapters::DataMapperAdapter.new(self)
        end

        module ClassMethods
          def sorcery_adapter
            Sorcery::Adapters::DataMapperAdapter.from(self)
          end
        end
      end

      def increment(attr)
        @model[attr] ||= 0
        @model[attr] += 1
        @model
      end

      def update_attributes(attrs)
        attrs.each do |name, value|
          value = value.utc if value.is_a?(ActiveSupport::TimeWithZone)
          @model.send(:"#{name}=", value)
        end
        @model.class.get(@model.id).update(attrs)
      end

      def update_attribute(name, value)
        update_attributes(name => value)
      end

      def save(options = {})
        if options.key?(:validate) && !options[:validate]
          @model.save!
        else
          @model.save
        end
      end

      class << self
        def define_field(name, type, options={})
          @klass.property name, type, options.slice(:length, :default)

          # Workaround local timezone retrieval problem NOTE dm-core issue #193
          if type == Time
            @klass.send(:alias_method, "orig_#{name}", name)
            @klass.send :define_method, name do
              t = send("orig_#{name}")
              t && Time.new(t.year, t.month, t.day, t.hour, t.min, t.sec, 0)
            end
          end
        end

        def define_callback(time, event, method_name, options={})
          event = :valid? if event == :validation
          condition = options[:if]

          user_klass = @klass

          block = Proc.new do |record|
            if condition.nil?
              send(method_name)
            elsif condition.respond_to?(:call)
              send(method_name) if condition.call(self)
            elsif condition.is_a? Symbol
              send(method_name) if send(condition)
            end
          end

          @klass.send(time, event, &block)
        end

        def find(id)
          @klass.get(id)
        end

        def delete_all
          @klass.destroy
        end

        # NOTE
        # DM Adapter dependent
        # DM creates MySQL tables case insensitive by default
        # http://datamapper.lighthouseapp.com/projects/20609-datamapper/tickets/1105
        def find_by_credentials(credentials)
          credential = credentials[0].dup
          credential.downcase! if @klass.sorcery_config.downcase_username_before_authenticating
          @klass.sorcery_config.username_attribute_names.each do |name|
            @user = @klass.first(name => credential)
            break if @user
          end
          !!@user ? @klass.get(@user.id) : nil
        end

        def find_by_oauth_credentials(provider, uid)
          @user_config = ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
          user = @klass.first(@user_config.provider_attribute_name => provider, @user_config.provider_uid_attribute_name => uid)
          !!user ? @klass.get(user.id) : nil
        end

        def find_by_token(token_attr_name, token)
          @klass.first(token_attr_name => token)
        end

        def find_by_id(id)
          @klass.get(id)
        rescue ::DataMapper::ObjectNotFoundError
          nil
        end

        def find_by_activation_token(token)
          user = @klass.first(@klass.sorcery_config.activation_token_attribute_name => token)
          !!user ? @klass.get(user.id) : nil
        end

        def find_by_remember_me_token(token)
          user = @klass.first(@klass.sorcery_config.remember_me_token_attribute_name => token)
          !!user ? @klass.get(user.id) : nil
        end

        def find_by_username(username)
          user = nil
          @klass.sorcery_config.username_attribute_names.each do |name|
            user = @klass.first(name => username)
            break if user
          end
          !!user ? @klass.get(user.id) : nil
        end

        def transaction(&blk)
          @klass.tap(&blk)
        end

        def find_by_sorcery_token(token_attr_name, token)
          user = @klass.first(token_attr_name => token)
          !!user ? @klass.get(user.id) : nil
        end

        def find_by_email(email)
          user = @klass.first(@klass.sorcery_config.email_attribute_name => email)
          !!user ? @klass.get(user.id) : nil
        end

        # NOTE
        # DM Adapter dependent
        def get_current_users
          unless @klass.repository.adapter.is_a?(::DataMapper::Adapters::MysqlAdapter)
            raise 'Unsupported DataMapper Adapter'
          end
          config = @klass.sorcery_config
          ret = @klass.all(config.last_logout_at_attribute_name => nil) |
                @klass.all(config.last_activity_at_attribute_name.gt => config.last_logout_at_attribute_name)
          ret = ret.all(config.last_activity_at_attribute_name.not => nil)
          ret = ret.all(config.last_activity_at_attribute_name.gt => config.activity_timeout.seconds.ago.utc)
          ret
        end

        def verify_submodules_compatibility!
          active_submodules = [::Sorcery::Controller::Config.submodules].flatten

          if active_submodules.include?(:activity_logging) && !repository.adapter.is_a?(::DataMapper::Adapters::MysqlAdapter)
            raise "DataMapper adapter compatibility error, please check documentation"
          end
        end
      end
    end
  end
end
