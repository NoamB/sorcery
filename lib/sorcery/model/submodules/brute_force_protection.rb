module Sorcery
  module Model
    module Submodules
      # This module helps protect user accounts by locking them down after too many failed attemps
      # to login were detected.
      # This is the model part of the submodule which provides configuration options and methods
      # for locking and unlocking the user.
      module BruteForceProtection
        def self.included(base)
          base.sorcery_config.class_eval do
            attr_accessor :failed_logins_count_attribute_name,        # failed logins attribute name.
                          :lock_expires_at_attribute_name,            # this field indicates whether user
                                                                      # is banned and when it will be active again.
                          :consecutive_login_retries_amount_limit,    # how many failed logins allowed.
                          :login_lock_time_period,                    # how long the user should be banned.
                                                                      # in seconds. 0 for permanent.

                          :unlock_token_attribute_name,               # Unlock token attribute name
                          :unlock_token_email_method_name,            # Mailer method name
                          :unlock_token_mailer_disabled,              # When true, dont send unlock token via email
                          :unlock_token_mailer                        # Mailer class
          end

          base.sorcery_config.instance_eval do
            @defaults.merge!(:@failed_logins_count_attribute_name              => :failed_logins_count,
                             :@lock_expires_at_attribute_name                  => :lock_expires_at,
                             :@consecutive_login_retries_amount_limit          => 50,
                             :@login_lock_time_period                          => 60 * 60,

                             :@unlock_token_attribute_name                     => :unlock_token,
                             :@unlock_token_email_method_name                  => :send_unlock_token_email,
                             :@unlock_token_mailer_disabled                    => false,
                             :@unlock_token_mailer                             => nil)
            reset!
          end

          base.sorcery_config.before_authenticate << :prevent_locked_user_login
          base.sorcery_config.after_config << :define_brute_force_protection_fields
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end

        module ClassMethods
          def load_from_unlock_token(token)
            return nil if token.blank?
            user = sorcery_adapter.find_by_token(sorcery_config.unlock_token_attribute_name,token)
            user
          end

          protected

          def define_brute_force_protection_fields
            sorcery_adapter.define_field sorcery_config.failed_logins_count_attribute_name, Integer, :default => 0
            sorcery_adapter.define_field sorcery_config.lock_expires_at_attribute_name, Time
            sorcery_adapter.define_field sorcery_config.unlock_token_attribute_name, String
          end
        end

        module InstanceMethods
          # Called by the controller to increment the failed logins counter.
          # Calls 'lock!' if login retries limit was reached.
          def register_failed_login!
            config = sorcery_config
            return if !unlocked?

            sorcery_adapter.increment(config.failed_logins_count_attribute_name)

            if self.send(config.failed_logins_count_attribute_name) >= config.consecutive_login_retries_amount_limit
              lock!
            end
          end

          # /!\
          # Moved out of protected for use like activate! in controller
          # /!\
          def unlock!
            config = sorcery_config
            attributes = {config.lock_expires_at_attribute_name => nil,
                          config.failed_logins_count_attribute_name => 0,
                          config.unlock_token_attribute_name => nil}
            sorcery_adapter.update_attributes(attributes)
          end

          def locked?
            !unlocked?
          end

          protected

          def lock!
            config = sorcery_config
            attributes = {config.lock_expires_at_attribute_name => Time.now.in_time_zone + config.login_lock_time_period,
                          config.unlock_token_attribute_name => TemporaryToken.generate_random_token}
            sorcery_adapter.update_attributes(attributes)

            unless config.unlock_token_mailer_disabled || config.unlock_token_mailer.nil?
              send_unlock_token_email!
            end
          end

          def unlocked?
            config = sorcery_config
            self.send(config.lock_expires_at_attribute_name).nil?
          end

          def send_unlock_token_email!
            return if sorcery_config.unlock_token_email_method_name.nil?

            generic_send_email(:unlock_token_email_method_name, :unlock_token_mailer)
          end

          # Prevents a locked user from logging in, and unlocks users that expired their lock time.
          # Runs as a hook before authenticate.
          def prevent_locked_user_login
            config = sorcery_config
            if !self.unlocked? && config.login_lock_time_period != 0
              self.unlock! if self.send(config.lock_expires_at_attribute_name) <= Time.now.in_time_zone
            end
            unlocked?
          end
        end
      end
    end
  end
end
