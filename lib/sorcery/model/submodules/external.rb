module Sorcery
  module Model
    module Submodules
      # This submodule helps you login users from external providers such as Twitter.
      # This is the model part which handles finding the user using access tokens.
      # For the controller options see Sorcery::Controller::External.
      #
      # Socery assumes (read: requires) you will create external users in the same table where
      # you keep your regular users,
      # but that you will have a separate table for keeping their external authentication data,
      # and that that separate table has a few rows for each user, facebook and twitter
      # for example (a one-to-many relationship).
      #
      # External users will have a null crypted_password field, since we do not hold their password.
      # They will not be sent activation emails on creation.
      module External
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :authentications_class,
                          :authentications_user_id_attribute_name,
                          :provider_attribute_name,
                          :provider_uid_attribute_name

          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@authentications_class                  => nil,
                             :@authentications_user_id_attribute_name => :user_id,
                             :@provider_attribute_name                => :provider,
                             :@provider_uid_attribute_name            => :uid)

            reset!
          end

          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)

        end

        module ClassMethods
          # takes a provider and uid and finds a user by them.
          def load_from_provider(provider,uid)
            config = sorcery_config
            authentication = config.authentications_class.sorcery_adapter.find_by_oauth_credentials(provider, uid)
            user = sorcery_adapter.find_by_id(authentication.send(config.authentications_user_id_attribute_name)) if authentication
          end

          def create_and_validate_from_provider(provider, uid, attrs)
            user = new(attrs)
            user.send(sorcery_config.authentications_class.to_s.downcase.pluralize).build(
              sorcery_config.provider_uid_attribute_name => uid,
              sorcery_config.provider_attribute_name => provider
            )
            saved = user.sorcery_adapter.save
            [user, saved]
          end

          def create_from_provider(provider, uid, attrs)
            user = new
            attrs.each do |k,v|
              user.send(:"#{k}=", v)
            end

            if block_given?
              return false unless yield user
            end

            sorcery_adapter.transaction do
              user.sorcery_adapter.save(:validate => false)
              sorcery_config.authentications_class.create!(
                sorcery_config.authentications_user_id_attribute_name => user.id,
                sorcery_config.provider_attribute_name => provider,
                sorcery_config.provider_uid_attribute_name => uid
              )
            end
            user
          end
        end

        module InstanceMethods
          def add_provider_to_user(provider, uid)
            authentications = sorcery_config.authentications_class.name.underscore.pluralize
            # first check to see if user has a particular authentication already
            if sorcery_adapter.find_authentication_by_oauth_credentials(authentications, provider, uid).nil?
              user = send(authentications).build(sorcery_config.provider_uid_attribute_name => uid,
                                                 sorcery_config.provider_attribute_name => provider)
              user.sorcery_adapter.save(validate: false)
            else
              user = false
            end

            user
          end

        end

      end
    end
  end
end
