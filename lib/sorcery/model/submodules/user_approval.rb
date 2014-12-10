module Sorcery
  module Model
    module Submodules
      # This submodule adds the ability to make existing user approve newcomers
      module UserApproval
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :approval_state_attribute_name,
                          :user_approval_mailer,
                          :approval_mailer_disabled,
                          :waiting_approval_email_method_name,
                          :approval_success_email_method_name,
                          :prevent_not_approved_users_to_login
          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@approval_state_attribute_name       => :approval_state,
                             :@user_approval_mailer                => nil,
                             :@approval_mailer_disabled            => false,
                             :@waiting_approval_email_method_name  => :waiting_approval_email,
                             :@approval_success_email_method_name  => :approval_success_email,
                             :@prevent_not_approved_users_to_login => true)
            reset!
          end

          base.class_eval do
            # don't setup approval if no password supplied - this user is created automatically
            sorcery_adapter.define_callback :before, :create, :setup_approval, :if => Proc.new { |user| user.send(sorcery_config.password_attribute_name).present? }
            sorcery_adapter.define_callback :after, :create, :send_waiting_approval_email!, :if => :send_approval_success_email?
          end

          base.sorcery_config.after_config << :validate_mailer_defined
          base.sorcery_config.after_config << :define_user_approval_field
          base.sorcery_config.before_authenticate << :prevent_not_approved_login

          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)

        end

        module ClassMethods
          protected

          # This submodule requires the developer to define his own mailer class to be used by it
          # when approval_mailer_disabled is false
          def validate_mailer_defined
            msg = "To use user_approval submodule, you must define a mailer (config.user_approval_mailer = YourMailerClass)."
            raise ArgumentError, msg if @sorcery_config.user_approval_mailer == nil and @sorcery_config.approval_mailer_disabled == false
          end

          def define_user_approval_field
            self.class_eval do
              sorcery_adapter.define_field sorcery_config.approval_state_attribute_name, String
            end
          end
        end

        module InstanceMethods
          def setup_approval
            config = sorcery_config
            self.send(:"#{config.approval_state_attribute_name}=", "waiting")
          end

          # sets the use as 'approved' and optionaly sends a success email.
          def approve!
            config = sorcery_config
            self.send(:"#{config.approval_state_attribute_name}=", "approved")
            send_approval_success_email! if send_approval_success_email?
            sorcery_adapter.save(:validate => false, :raise_on_failure => true)
          end

          protected

          # called automatically after user initial creation.
          def send_waiting_approval_email!
            generic_send_email(:waiting_approval_email_method_name, :user_approval_mailer)
          end

          def send_approval_success_email!
            generic_send_email(:approval_success_email_method_name, :user_approval_mailer)
          end

          def send_approval_success_email?
            !(sorcery_config.approval_success_email_method_name.nil? ||
              sorcery_config.approval_mailer_disabled == true)
          end

          def send_waiting_approval_email?
            !(sorcery_config.waiting_approval_email_method_name.nil? ||
              sorcery_config.approval_mailer_disabled == true)
          end

          def prevent_not_approved_login
            config = sorcery_config
            config.prevent_not_approved_users_to_login ? self.send(config.approval_state_attribute_name) == "approved" : true
          end

        end
      end
    end
  end
end
