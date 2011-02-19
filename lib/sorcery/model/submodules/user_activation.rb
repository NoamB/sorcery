module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to make the user activate his account via email
      # or any other way in which he can recieve an activation code.
      # with the activation code the user may activate his account.
      # When using this submodule, supplying a mailer is mandatory.
      module UserActivation
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :activation_state_attribute_name,         # the attribute name to hold activation state (active/pending).
                          :activation_code_attribute_name,          # the attribute name to hold activation code (sent by email).
                          :user_activation_mailer,                  # your mailer class. Needed.
                          :activation_needed_email_method_name,     # activation needed email method on your mailer class.
                          :activation_success_email_method_name,    # activation success email method on your mailer class.
                          :prevent_non_active_users_to_login        # do you want to prevent or allow users that did not activate by email to login?
          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@activation_state_attribute_name      => :activation_state,
                             :@activation_code_attribute_name       => :activation_code,
                             :@user_activation_mailer               => nil,
                             :@activation_needed_email_method_name  => :activation_needed_email,
                             :@activation_success_email_method_name => :activation_success_email,
                             :@prevent_non_active_users_to_login    => true)
            reset!
          end
          
          base.class_eval do
            before_create :setup_activation
            after_create :send_activation_needed_email!
          end
          
          base.sorcery_config.after_config << :validate_mailer_defined
          
          base.sorcery_config.before_authenticate << :prevent_non_active_login
          
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end
        
        module ClassMethods
          protected
          
          # This submodule requires the developer to define his own mailer class to be used by it.
          def validate_mailer_defined
            msg = "To use user_activation submodule, you must define a mailer (config.user_activation_mailer = YourMailerClass)."
            raise ArgumentError, msg if @sorcery_config.user_activation_mailer == nil
          end
        end
        
        module InstanceMethods
          # clears activation code, sets the user as 'active' and optionaly sends a success email.
          def activate!
            config = sorcery_config
            self.send(:"#{config.activation_code_attribute_name}=", nil)
            self.send(:"#{config.activation_state_attribute_name}=", "active")
            send_activation_success_email!
            save!(:validate => false) # don't run validations
          end

          protected

          def setup_activation
            config = sorcery_config
            generated_activation_code = CryptoProviders::SHA1.encrypt( Time.now.to_s.split(//).sort_by {rand}.join )
            self.send(:"#{config.activation_code_attribute_name}=", generated_activation_code)
            self.send(:"#{config.activation_state_attribute_name}=", "pending")
          end

          # called automatically after user initial creation.
          def send_activation_needed_email!
            generic_send_email(:activation_needed_email_method_name, :user_activation_mailer) unless sorcery_config.activation_needed_email_method_name.nil?
          end

          def send_activation_success_email!
            generic_send_email(:activation_success_email_method_name, :user_activation_mailer) unless sorcery_config.activation_success_email_method_name.nil?
          end
          
          def prevent_non_active_login
            config = sorcery_config
            config.prevent_non_active_users_to_login ? self.send(config.activation_state_attribute_name) == "active" : true
          end

        end
      end
    end
  end
end