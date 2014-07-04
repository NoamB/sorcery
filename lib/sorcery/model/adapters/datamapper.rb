module Sorcery
  module Model
    module Adapters
      module DataMapper
        def self.included(klass)
          klass.extend ClassMethods
          klass.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def increment(attr)
            self[attr] ||= 0
            self[attr] += 1
            self
          end

          def update_many_attributes(attrs)
            attrs.each do |name, value|
              value = value.utc if value.is_a?(ActiveSupport::TimeWithZone)
              self.send(:"#{name}=", value)
            end
            self.class.get(self.id).update(attrs)
          end

          def update_single_attribute(name, value)
            update_many_attributes(name => value)
          end

          def sorcery_save(options = {})
            if options.key?(:validate) && ! options[:validate]
              save!
            else
              save
            end
          end
        end

        module ClassMethods
          def define_field(name, type, options={})
            property name, type, options.slice(:length, :default)

            # Workaround local timezone retrieval problem NOTE dm-core issue #193
            if type == Time
              alias_method "orig_#{name}", name
              define_method(name) do
                t = send("orig_#{name}")
                t && Time.new(t.year, t.month, t.day, t.hour, t.min, t.sec, 0)
              end
            end
          end

          def define_callback(time, event, method_name, options={})
            event = :valid? if event == :validation
            condition = options[:if]

            block = Proc.new do |record|
              if condition.nil?
                send(method_name)
              elsif condition.respond_to?(:call)
                send(method_name) if condition.call(self)
              elsif condition.is_a? Symbol
                send(method_name) if send(condition)
              end
            end

            send(time, event, &block)
          end

          def find(id)
            get(id)
          end

          def delete_all
            destroy
          end

          # NOTE
          # DM Adapter dependent
          # DM creates MySQL tables case insensitive by default
          # http://datamapper.lighthouseapp.com/projects/20609-datamapper/tickets/1105
          def find_by_credentials(credentials)
            credential = credentials[0].dup
            credential.downcase! if @sorcery_config.downcase_username_before_authenticating
            @sorcery_config.username_attribute_names.each do |name|
              @user = first(name => credential)
              break if @user
            end
            !!@user ? get(@user.id) : nil
          end

          def find_by_oauth_credentials(provider, uid)
            @user_config = ::Sorcery::Controller::Config.user_class.to_s.constantize.sorcery_config
            user = first(@user_config.provider_attribute_name => provider, @user_config.provider_uid_attribute_name => uid)
            !!user ? get(user.id) : nil
          end

          def find_by_id(id)
            find(id)
          rescue ::DataMapper::ObjectNotFoundError
            nil
          end

          def find_by_activation_token(token)
            user = first(sorcery_config.activation_token_attribute_name => token)
            !!user ? get(user.id) : nil
          end

          def find_by_remember_me_token(token)
            user = first(sorcery_config.remember_me_token_attribute_name => token)
            !!user ? get(user.id) : nil
          end

          def find_by_username(username)
            user = nil
            sorcery_config.username_attribute_names.each do |name|
              user = first(name => username)
              break if user
            end
            !!user ? get(user.id) : nil
          end

          def transaction(&blk)
            tap(&blk)
          end

          def find_by_sorcery_token(token_attr_name, token)
            user = first(token_attr_name => token)
            !!user ? get(user.id) : nil
          end

          def find_by_email(email)
            user = first(sorcery_config.email_attribute_name => email)
            !!user ? get(user.id) : nil
          end

          # NOTE
          # DM Adapter dependent
          def get_current_users
            unless self.repository.adapter.is_a?(::DataMapper::Adapters::MysqlAdapter)
              raise 'Unsupported DataMapper Adapter'
            end
            config = sorcery_config
            ret = all(config.last_logout_at_attribute_name => nil) |
                  all(config.last_activity_at_attribute_name.gt => config.last_logout_at_attribute_name)
            ret = ret.all(config.last_activity_at_attribute_name.not => nil)
            ret = ret.all(config.last_activity_at_attribute_name.gt => config.activity_timeout.seconds.ago.utc)
            ret
          end
        end
      end
    end
  end
end
