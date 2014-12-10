module Sorcery
  module TestHelpers
    # Internal TestHelpers are used to test the gem, internally, and should not be used to test apps *using* sorcery.
    # This file will be included in the spec_helper file.
    module Internal
      def self.included(base)
        # reducing default cost for specs speed
        CryptoProviders::BCrypt.class_eval do
          class << self
            def cost
              1
            end
          end
        end
      end

      # a patch to fix a bug in testing that happens when you 'destroy' a session twice.
      # After the first destroy, the session is an ordinary hash, and then when destroy
      # is called again there's an exception.
      class ::Hash
        def destroy
          clear
        end
      end

      def build_new_user(attributes_hash = nil)
        user_attributes_hash = attributes_hash || {:username => 'gizmo', :email => "bla@bla.com", :password => 'secret'}
        @user = User.new(user_attributes_hash)
      end

      def create_new_user(attributes_hash = nil)
        @user = build_new_user(attributes_hash)
        @user.sorcery_adapter.save(:raise_on_failure => true)
        @user
      end

      def create_new_external_user(provider, attributes_hash = nil)
        user_attributes_hash = attributes_hash || {:username => 'gizmo'}
        @user = User.new(user_attributes_hash)
        @user.sorcery_adapter.save(:raise_on_failure => true)
        @user.authentications.create!({:provider => provider, :uid => 123})
        @user
      end

      def custom_create_new_external_user(provider, authentication_class, attributes_hash = nil)
        authentication_association = authentication_class.name.underscore.pluralize

        user_attributes_hash = attributes_hash || {:username => 'gizmo'}
        @user = User.new(user_attributes_hash)
        @user.sorcery_adapter.save(:raise_on_failure => true)
        @user.send(authentication_association).create!({:provider => provider, :uid => 123})
        @user
      end

      def sorcery_model_property_set(property, *values)
        User.class_eval do
          sorcery_config.send(:"#{property}=", *values)
        end
      end

      def update_model(&block)
        User.class_exec(&block)
      end

      private

      # reload user class between specs
      # so it will be possible to test the different submodules in isolation
      def reload_user_class
        Object.send(:remove_const, "User")
        load 'user.rb'
        if User.respond_to?(:reset_column_information)
          User.reset_column_information
        end
      end
    end
  end
end
