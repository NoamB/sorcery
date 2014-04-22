module Sorcery
  module Model
    module Submodules
      # This module helps protect user accounts by requiring regular password changes.
      # This is the model part of the submodule which provides configuration options and methods
      # for requiring the user change their password regularly.
      module PasswordExpiration
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :password_changed_at_attribute_name,  # this field indicates when the user
                                                                # last changed their password.
                          :password_expiration_time_period      # how long the current password is valid after
                                                                # change before expiring (in seconds).
          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@password_changed_at_attribute_name  => :password_changed_at,
                             :@password_expiration_time_period     => 90.days)
            reset!
          end

          base.class_eval do
            if defined?(DataMapper) && self.ancestors.include?(DataMapper::Resource)
              before :save, :update_password_changed_at
            else
              before_save :update_password_changed_at
            end
          end

          if defined?(Mongoid) && base.ancestors.include?(Mongoid::Document)
            base.sorcery_config.after_config << :define_password_expiration_mongoid_fields
          end
          if defined?(MongoMapper) && base.ancestors.include?(MongoMapper::Document)
            base.sorcery_config.after_config << :define_password_expiration_mongo_mapper_fields
          end
          if defined?(DataMapper) && base.ancestors.include?(DataMapper::Resource)
            base.sorcery_config.after_config << :define_password_expiration_datamapper_fields
          end
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end

        module ClassMethods
          protected

          def define_password_expiration_mongoid_fields
            field sorcery_config.password_changed_at_attribute_name, :type => Time
          end

          def define_password_expiration_mongo_mapper_fields
            key sorcery_config.password_changed_at_attribute_name, Time
          end

          def define_password_expiration_datamapper_fields
            property sorcery_config.password_changed_at_attribute_name, Time
            # Workaround local timezone retrieval problem NOTE dm-core issue #193
            [sorcery_config.password_changed_at_attribute_name].each do |sym|
              alias_method "orig_#{sym}", sym
              define_method(sym) do
                t = send("orig_#{sym}")
                t && Time.new(t.year, t.month, t.day, t.hour, t.min, t.sec, 0)
              end
            end
          end
        end

        module InstanceMethods
          def need_password_changed?
            expired_if_before_date = self.class.sorcery_config.password_expiration_time_period.ago
            _password_changed_at = self.send(sorcery_config.password_changed_at_attribute_name)
            _password_changed_at.nil? || (_password_changed_at < expired_if_before_date)
          end

          def need_password_changed!
            expiration_date = self.class.sorcery_config.password_expiration_time_period.ago
            self.send("#{sorcery_config.password_changed_at_attribute_name}=", expiration_date)
            self.sorcery_save
          end

          def update_password!(params = {})
            _current_password      = params[:current_password]
            _password              = params[:password]
            _password_confirmation = params[:password_confirmation]

            return false unless _password == _password_confirmation

            _salt = self.send(sorcery_config.salt_attribute_name) unless sorcery_config.salt_attribute_name.nil? || sorcery_config.encryption_provider.nil?
            if self.class.send(:credentials_match?, self.send(sorcery_config.crypted_password_attribute_name), _current_password, _salt)
              self.send("#{sorcery_config.password_attribute_name}=", _password)
              self.sorcery_save
            else
              false
            end
          end

          protected

          def update_password_changed_at
            if (_new_record? || password_attr_changed?) && password_changed_at_attr_not_changed?
              self.send("#{sorcery_config.password_changed_at_attribute_name}=", Time.now)
            end
          end

          private

          def _new_record?
            if defined?(DataMapper) && self.class.ancestors.include?(DataMapper::Resource)
              self.new?
            else
              self.new_record?
            end
          end

          def password_attr_changed?
            self.send(sorcery_config.password_attribute_name).present? ||
              crypted_password_attr_changed?
          end

          def crypted_password_attr_changed?
            if defined?(DataMapper) && self.class.ancestors.include?(DataMapper::Resource)
              self.attribute_dirty?(sorcery_config.crypted_password_attribute_name)
            else
              self.send("#{sorcery_config.crypted_password_attribute_name}_changed?")
            end
          end

          def password_changed_at_attr_not_changed?
            if defined?(DataMapper) && self.class.ancestors.include?(DataMapper::Resource)
              !self.attribute_dirty?(sorcery_config.password_changed_at_attribute_name)
            else
              !self.send("#{sorcery_config.password_changed_at_attribute_name}_changed?")
            end
          end
        end
      end
    end
  end
end
