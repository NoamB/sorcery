module Sorcery
  module Model
    module Adapters
      module MongoMapper
        def self.included(klass)
          klass.extend ClassMethods
          klass.send(:include, InstanceMethods)
        end
        
        module InstanceMethods
          def increment(attr)
            self.inc(attr,1)
          end
          
          def save!(options={})
            save(options={})
          end
        end

        module ClassMethods
          def find_by_credentials(credentials)
            @sorcery_config.username_attribute_names.each do |attribute|
              @user = where(attribute => credentials[0]).first
              break if @user
            end
            @user
          end
          
          def find_by_id(id)
            find(id)
          end
          
          def find_by_activation_token(token)
            where(sorcery_config.activation_token_attribute_name => token).first
          end
          
          def transaction(&blk)
            tap(&blk)
          end
          
          def find_by_sorcery_token(token_attr_name, token)
            where(token_attr_name => token).first
          end
        end
      end
    end
  end
end
