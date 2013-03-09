module Sorcery
  module Controller
    module Submodules
      #
      # Access Token submodule
      #
      # Registers an alternative login source which is used to handle
      # the user's client requests by checking the validity of the api_access_token.
      #
      # It also register two methods to be run after user login/logout to
      # handle the creation and deletion of api_access_tokens.
      #
      # See Sorcery::Model::Submodules::AccessToken for configuration options
      #
      module AccessToken
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              def merge_access_token_defaults!
                @defaults.merge!(:@restful_json_api => true)
              end
            end
            merge_access_token_defaults!
          end

          Config.login_sources << :login_from_access_token
          Config.after_login << :set_access_token
          Config.after_logout << :destroy_access_token
        end

        module InstanceMethods

          def auto_login(user, create_token = false)
            @current_user = user
            set_access_token(user) if create_token
          end

          protected

          # Allow client request iff its access_token is valid,
          # update token last_activity_at (if feature is enabled)
          def login_from_access_token
            @api_access_token = nil
            client_token  = params[:access_token].to_s
            access_token  = ::AccessToken.find_token(client_token)
            if access_token && access_token.valid?(:auth)
              update_token_last_activity_time(access_token)
              @api_access_token = access_token.reload
              @current_user = access_token.user
            else
              @current_user = false
            end
          end

          # Update access token last_activity_at to current time iff 'duration'
          # and 'duration_from_last_activity' are both enabled
          def update_token_last_activity_time(access_token)
            config = user_class.sorcery_config
            if (config.access_token_register_last_activity ||
                (config.access_token_duration &&
                 config.access_token_duration_from_last_activity))

                access_token.update_last_activity_time
                access_token.save!
            end
          end

          # Set an access_token for client after successful login,
          # attempts to create a new token first, if max number of allowed
          # tokens has been reached it assigns one of the stored tokens.
          # This method deletes user invalid access tokens as side effect.
          def set_access_token(user, credentials = nil)
            @api_access_token ||= user.create_access_token!
            @api_access_token ||= user.reload.access_tokens.last
            !!@api_access_token
          end

          # Destroy access token after client logout
          def destroy_access_token
            if @api_access_token.delete
              @api_access_token = nil
              true
            else
              false
            end
          end

        end
      end
    end
  end
end
