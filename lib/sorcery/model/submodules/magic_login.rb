module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to login via email without password.
      # When the user requests an email is sent to him with a url.
      # The url includes a token, which is also saved with the user's record in the db.
      # The token has configurable expiration.
      # When the user clicks the url in the email, providing the token has not yet expired,
      # he will be able to login.
      #
      # When using this submodule, supplying a mailer is mandatory.
      module MagicLogin
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :magic_login_token_attribute_name,              # magic login code attribute name.
                          :magic_login_token_expires_at_attribute_name,   # expires at attribute name.
                          :magic_login_email_sent_at_attribute_name,      # when was email sent, used for hammering
                                                                             # protection.

                          :magic_login_mailer,                            # mailer class. Needed.

                          :magic_login_mailer_disabled,                   # when true sorcery will not automatically
                                                                             # email magic login details and allow you to
                                                                             # manually handle how and when email is sent

                          :magic_login_email_method_name,                 # magic login email method on your
                                                                             # mailer class.

                          :magic_login_expiration_period,                 # how many seconds before the request
                                                                             # expires. nil for never expires.

                          :magic_login_time_between_emails                # hammering protection, how long to wait
                                                                             # before allowing another email to be sent.

          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@magic_login_token_attribute_name            => :magic_login_token,
                             :@magic_login_token_expires_at_attribute_name => :magic_login_token_expires_at,
                             :@magic_login_email_sent_at_attribute_name    => :magic_login_email_sent_at,
                             :@magic_login_mailer                          => nil,
                             :@magic_login_mailer_disabled                 => false,
                             :@magic_login_email_method_name               => :magic_login_email,
                             :@magic_login_expiration_period               => 15 * 60,
                             :@magic_login_time_between_emails             => 5 * 60 )

            reset!
          end

          base.extend(ClassMethods)

          base.sorcery_config.after_config << :validate_mailer_defined
          base.sorcery_config.after_config << :define_magic_login_fields

          base.send(:include, InstanceMethods)

        end

        module ClassMethods
          # Find user by token, also checks for expiration.
          # Returns the user if token found and is valid.
          def load_from_magic_login_token(token)
            token_attr_name = @sorcery_config.magic_login_token_attribute_name
            token_expiration_date_attr = @sorcery_config.magic_login_token_expires_at_attribute_name
            load_from_token(token, token_attr_name, token_expiration_date_attr)
          end

          protected

          # This submodule requires the developer to define his own mailer class to be used by it
          # when magic_login_mailer_disabled is false
          def validate_mailer_defined
            msg = "To use magic_login submodule, you must define a mailer (config.magic_login_mailer = YourMailerClass)."
            raise ArgumentError, msg if @sorcery_config.magic_login_mailer == nil and @sorcery_config.magic_login_mailer_disabled == false
          end

          def define_magic_login_fields
            sorcery_adapter.define_field sorcery_config.magic_login_token_attribute_name, String
            sorcery_adapter.define_field sorcery_config.magic_login_token_expires_at_attribute_name, Time
            sorcery_adapter.define_field sorcery_config.magic_login_email_sent_at_attribute_name, Time
          end

        end

        module InstanceMethods
          # generates a reset code with expiration
          def generate_magic_login_token!
            config = sorcery_config
            attributes = {config.magic_login_token_attribute_name => TemporaryToken.generate_random_token,
                          config.magic_login_email_sent_at_attribute_name => Time.now.in_time_zone}
            attributes[config.magic_login_token_expires_at_attribute_name] = Time.now.in_time_zone + config.magic_login_expiration_period if config.magic_login_expiration_period

            self.sorcery_adapter.update_attributes(attributes)
          end

          # generates a magic login code with expiration and sends an email to the user.
          def deliver_magic_login_instructions!
            mail = false
            config = sorcery_config
            # hammering protection
            return false if config.magic_login_time_between_emails.present? && self.send(config.magic_login_email_sent_at_attribute_name) && self.send(config.magic_login_email_sent_at_attribute_name) > config.magic_login_time_between_emails.seconds.ago.utc
            self.class.sorcery_adapter.transaction do
              generate_magic_login_token!
              mail = send_magic_login_email! unless config.magic_login_mailer_disabled
            end
            mail
          end

          # Clears the token.
          def clear_magic_login_token!
            config = sorcery_config
            self.sorcery_adapter.update_attributes({
              config.magic_login_token_attribute_name => nil,
              config.magic_login_token_expires_at_attribute_name => nil
            })
          end

          protected

          def send_magic_login_email!
            generic_send_email(:magic_login_email_method_name, :magic_login_mailer)
          end
        end

      end
    end
  end
end
