module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to reset password via email confirmation.
      # When the user requests an email is sent to him with a url.
      # The url includes a token, which is also saved with the user's record in the db.
      # The token has configurable expiration.
      # When the user clicks the url in the email, providing the token has not yet expired,
      # he will be able to reset his password via a form.
      #
      # When using this submodule, supplying a mailer is mandatory.
      module ResetPassword
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :reset_password_token_attribute_name,              # reset password code attribute name.
                          :reset_password_token_expires_at_attribute_name,   # expires at attribute name.
                          :reset_password_email_sent_at_attribute_name,      # when was email sent, used for hammering
                                                                             # protection.

                          :reset_password_mailer,                            # mailer class. Needed.

                          :reset_password_mailer_disabled,                   # when true sorcery will not automatically
                                                                             # email password reset details and allow you to
                                                                             # manually handle how and when email is sent

                          :reset_password_email_method_name,                 # reset password email method on your
                                                                             # mailer class.

                          :reset_password_expiration_period,                 # how many seconds before the reset request
                                                                             # expires. nil for never expires.

                          :reset_password_time_between_emails                # hammering protection, how long to wait
                                                                             # before allowing another email to be sent.

          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@reset_password_token_attribute_name            => :reset_password_token,
                             :@reset_password_token_expires_at_attribute_name => :reset_password_token_expires_at,
                             :@reset_password_email_sent_at_attribute_name    => :reset_password_email_sent_at,
                             :@reset_password_mailer                          => nil,
                             :@reset_password_mailer_disabled                 => false,
                             :@reset_password_email_method_name               => :reset_password_email,
                             :@reset_password_expiration_period               => nil,
                             :@reset_password_time_between_emails             => 5 * 60 )

            reset!
          end

          base.extend(ClassMethods)

          base.sorcery_config.after_config << :validate_mailer_defined
          base.sorcery_config.after_config << :define_reset_password_fields

          base.send(:include, InstanceMethods)

        end

        module ClassMethods
          # Find user by token, also checks for expiration.
          # Returns the user if token found and is valid.
          def load_from_reset_password_token(token)
            token_attr_name = @sorcery_config.reset_password_token_attribute_name
            token_expiration_date_attr = @sorcery_config.reset_password_token_expires_at_attribute_name
            load_from_token(token, token_attr_name, token_expiration_date_attr)
          end

          protected

          # This submodule requires the developer to define his own mailer class to be used by it
          # when reset_password_mailer_disabled is false
          def validate_mailer_defined
            msg = "To use reset_password submodule, you must define a mailer (config.reset_password_mailer = YourMailerClass)."
            raise ArgumentError, msg if @sorcery_config.reset_password_mailer == nil and @sorcery_config.reset_password_mailer_disabled == false
          end

          def define_reset_password_fields
            sorcery_adapter.define_field sorcery_config.reset_password_token_attribute_name, String
            sorcery_adapter.define_field sorcery_config.reset_password_token_expires_at_attribute_name, Time
            sorcery_adapter.define_field sorcery_config.reset_password_email_sent_at_attribute_name, Time
          end

        end

        module InstanceMethods
          # generates a reset code with expiration
          def generate_reset_password_token!
            config = sorcery_config
            attributes = {config.reset_password_token_attribute_name => TemporaryToken.generate_random_token,
                          config.reset_password_email_sent_at_attribute_name => Time.now.in_time_zone}
            attributes[config.reset_password_token_expires_at_attribute_name] = Time.now.in_time_zone + config.reset_password_expiration_period if config.reset_password_expiration_period

            self.sorcery_adapter.update_attributes(attributes)
          end

          # generates a reset code with expiration and sends an email to the user.
          def deliver_reset_password_instructions!
            config = sorcery_config
            # hammering protection
            return false if config.reset_password_time_between_emails.present? && self.send(config.reset_password_email_sent_at_attribute_name) && self.send(config.reset_password_email_sent_at_attribute_name) > config.reset_password_time_between_emails.seconds.ago.utc
            self.class.sorcery_adapter.transaction do
              generate_reset_password_token!
              send_reset_password_email! unless config.reset_password_mailer_disabled
            end
          end

          # Clears token and tries to update the new password for the user.
          def change_password!(new_password)
            clear_reset_password_token
            self.send(:"#{sorcery_config.password_attribute_name}=", new_password)
            sorcery_adapter.save
          end

          protected

          def send_reset_password_email!
            generic_send_email(:reset_password_email_method_name, :reset_password_mailer)
          end

          # Clears the token.
          def clear_reset_password_token
            config = sorcery_config
            self.send(:"#{config.reset_password_token_attribute_name}=", nil)
            self.send(:"#{config.reset_password_token_expires_at_attribute_name}=", nil) if config.reset_password_expiration_period
          end
        end

      end
    end
  end
end
