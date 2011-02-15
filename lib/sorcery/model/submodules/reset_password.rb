module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to reset password via email confirmation.
      module ResetPassword       
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :reset_password_token_attribute_name,              # reset password code attribute name.
                          :reset_password_token_expires_at_attribute_name,   # expires at attribute name.
                          :reset_password_email_sent_at_attribute_name,      # when was email sent, used for hammering protection.
                          :reset_password_mailer,                            # mailer class. Needed.
                          :reset_password_email_method_name,                 # reset password email method on your mailer class.
                          :reset_password_expiration_period,                 # how many seconds before the reset request expires. nil for never expires.
                          :reset_password_time_between_emails                # hammering protection, how long to wait before allowing another email to be sent.

          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@reset_password_token_attribute_name            => :reset_password_token,
                             :@reset_password_token_expires_at_attribute_name => :reset_password_token_expires_at,
                             :@reset_password_email_sent_at_attribute_name    => :reset_password_email_sent_at,
                             :@reset_password_mailer                          => nil,
                             :@reset_password_email_method_name               => :reset_password_email,
                             :@reset_password_expiration_period               => nil,
                             :@reset_password_time_between_emails             => 5.minutes )

            reset!
          end
          
          base.sorcery_config.after_config << :validate_mailer_defined
          
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end
        
        module ClassMethods
          
          def load_from_reset_password_token(token)
            return nil if token.blank?
            user = where("#{@sorcery_config.reset_password_token_attribute_name} = ?", token).first
            if !user.blank? && !@sorcery_config.reset_password_expiration_period.nil?
              return (user.reset_password_token_valid? ? user : nil)
            end
            user
          end
          
          protected
          
          def validate_mailer_defined
            msg = "To use reset_password submodule, you must define a mailer (config.reset_password_mailer = YourMailerClass)."
            raise ArgumentError, msg if @sorcery_config.reset_password_mailer == nil
          end

        end
        
        module InstanceMethods
          # generates a reset code with expiration and sends an email to the user.
          def deliver_reset_password_instructions!
            config = sorcery_config
            # hammering protection
            return if self.send(config.reset_password_email_sent_at_attribute_name) && self.send(config.reset_password_email_sent_at_attribute_name) > config.reset_password_time_between_emails.ago.utc
            
            self.send(:"#{config.reset_password_token_attribute_name}=", generate_random_code)
            self.send(:"#{config.reset_password_token_expires_at_attribute_name}=", Time.now.utc+config.reset_password_expiration_period) if config.reset_password_expiration_period
            self.send(:"#{config.reset_password_email_sent_at_attribute_name}=", Time.now.utc)
            self.class.transaction do
              self.save!(:validate => false)
              generic_send_email(:reset_password_email_method_name, :reset_password_mailer)
            end
          end
          
          def reset_password!(params)
            clear_reset_password_token
            update_attributes(params)
          end
          
          def reset_password_token_valid?
            config = sorcery_config
            config.reset_password_expiration_period ? Time.now.utc < self.send(config.reset_password_token_expires_at_attribute_name) : true
          end

          protected

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