module Sorcery
  module Controller
    module Submodules
      # This submodule helps protect user accounts by requiring regular password changes.
      # This is the controller part of the submodule, which adds hooks
      # to require a user to change their password.
      # see Socery::Model::Submodules::PasswordExpiration for configuration
      # options.
      module PasswordExpiration
        def self.included(base)
          base.send(:include, InstanceMethods)
          Config.module_eval do
            class << self
              attr_accessor :change_password_action

              def merge_password_expiration_defaults!
                @defaults.merge!(:@change_password_action => :change_password)
              end
            end
            merge_password_expiration_defaults!
          end
        end

        module InstanceMethods
          # To be used as before_filter.
          # If password is expired, the failure callback will be called.
          def require_valid_password
            if logged_in? && current_user.password_expired?
              session[:return_to_url] = request.url if Config.save_return_to_url && request.get?
              self.send(Config.change_password_action)
            end
          end

          # The default action for denying users with expired passwords.
          # You can override this method in your controllers,
          # or provide a different method in the configuration.
          def change_password
            redirect_to root_url
          end
        end
      end
    end
  end
end
