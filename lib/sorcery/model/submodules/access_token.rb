module Sorcery
  module Model
    module Submodules
      #
      # Access Token submodule
      #
      # Handles the creation and deletion of user access_tokens,
      #
      module AccessToken
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor(:access_token_mode,
                          :access_token_duration,
                          :access_token_duration_from_last_activity,
                          :access_token_max_per_user,
                          :access_token_register_last_activity)
          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@access_token_mode => 'single_token',
                             :@access_token_duration => nil,
                             :@access_token_duration_from_last_activity => false,
                             :@access_token_max_per_user => nil,
                             :@access_token_register_last_activity => false)

            reset!
          end

          base.send(:include, InstanceMethods)

          if defined?(Mongoid) && base.ancestors.include?(Mongoid::Document)
            base.sorcery_config.after_config << :define_access_token_mongoid_fields
          end
          if defined?(MongoMapper) && base.ancestors.include?(MongoMapper::Document)
            base.sorcery_config.after_config << :define_access_token_mongo_mapper_fields
          end

          base.sorcery_config.after_config << :register_access_token_creation_callback

          base.extend(ClassMethods)
        end

        module ClassMethods
          protected

            def define_access_token_mongoid_fields
              include Mongoid::Timestamps
              field :user_id, :type => Integer
              field :token, :type => String
              field :expirable, :type => Boolean, :default => true
              field :last_activity_at, :type => Time
            end

            def define_access_token_mongo_mapper_fields
              key :token, String
              key :expirable, Boolean, :default => true
              key :last_activity_at, Time
              timestamps!
            end

            # Register conditional create_access_token on after_create callback,
            # create token after user creation when mode is set to 'single_token'
            def register_access_token_creation_callback
              after_create do
                create_access_token!(:user_creation)
              end
            end
        end

        module InstanceMethods
          # Create and return access token, or nil if nothing was created,
          # it has the side effect of destroying user invalid tokens.
          # Creation conditions:
          #   * session mode : number of valid stored tokens must be less than
          #                    value defined in max_per_user (if any).
          #   * single_token mode : stored token must be invalid or nonexistent.
          def create_access_token!(context = nil)
            access_token_mode = sorcery_config.access_token_mode.to_s
            max = sorcery_config.access_token_max_per_user
            delete_expired_access_tokens
            self.reload
            if access_token_mode == 'session' && context != :user_creation
              if ! max || access_tokens.count < max.to_i
                access_tokens.create!
              end
            elsif access_token_mode == 'single_token' && access_tokens.empty?
              access_tokens.create!
            end
          end

          # Delete user expired access tokens
          def delete_expired_access_tokens
            ::AccessToken.delete_expired(self.id)
          end

        end
      end
    end
  end
end
