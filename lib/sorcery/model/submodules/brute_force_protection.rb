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
                          :login_lock_time_period                     # how long the user should be banned. 
                                                                      # in seconds. 0 for permanent.
          end
          
          base.sorcery_config.instance_eval do
            @defaults.merge!(:@failed_logins_count_attribute_name              => :failed_logins_count,
                             :@lock_expires_at_attribute_name                  => :lock_expires_at,
                             :@consecutive_login_retries_amount_limit          => 50,
                             :@login_lock_time_period                          => 60 * 60)
            reset!
          end
          
          base.sorcery_config.before_authenticate << :prevent_locked_user_login
          base.sorcery_config.after_config << :define_brute_force_protection_mongoid_fields if defined?(Mongoid) and base.ancestors.include?(Mongoid::Document)
          if defined?(MongoMapper) and base.ancestors.include?(MongoMapper::Document)
            base.sorcery_config.after_config << :define_brute_force_protection_mongo_mapper_fields
          end
          base.extend(ClassMethods)
          base.send(:include, InstanceMethods)
        end
        
        module ClassMethods
          protected

          def define_brute_force_protection_mongoid_fields
            field sorcery_config.failed_logins_count_attribute_name,  :type => Integer, :default => 0
            field sorcery_config.lock_expires_at_attribute_name,      :type => Time
          end

          def define_brute_force_protection_mongo_mapper_fields
            key sorcery_config.failed_logins_count_attribute_name, Integer, :default => 0
            key sorcery_config.lock_expires_at_attribute_name, Time
          end
        end
        
        module InstanceMethods
          # Called by the controller to increment the failed logins counter.
          # Calls 'lock!' if login retries limit was reached.
          def register_failed_login!
            config = sorcery_config
            return if !unlocked?
            self.increment(config.failed_logins_count_attribute_name)
            self.save!(:validate => false)
            self.lock! if self.send(config.failed_logins_count_attribute_name) >= config.consecutive_login_retries_amount_limit
          end
          
          protected

          def lock!
            config = sorcery_config
            self.send(:"#{config.lock_expires_at_attribute_name}=", Time.now.in_time_zone + config.login_lock_time_period)
            self.save!(:validate => false)
          end

          def unlock!
            config = sorcery_config
            self.send(:"#{config.lock_expires_at_attribute_name}=", nil)
            self.send(:"#{config.failed_logins_count_attribute_name}=", 0)
            self.save!(:validate => false)
          end
          
          def unlocked?
            config = sorcery_config
            self.send(config.lock_expires_at_attribute_name).nil?
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
