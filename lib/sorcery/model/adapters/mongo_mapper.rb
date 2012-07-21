module Sorcery
  module Model
    module Adapters
      module MongoMapper
        extend ActiveSupport::Concern

        included do
          include Sorcery::Model
        end

        def increment(attr)
          self.class.increment(id, attr => 1)
        end

        def save!(options = {})
          save(options)
        end

        def update_many_attributes(attrs)
          update_attributes(attrs)
        end

        module ClassMethods
          def credential_regex(credential)
            return { :$regex =>  /^#{credential}$/i  }  if (@sorcery_config.downcase_username_before_authenticating)
            return credential
          end

          def find_by_credentials(credentials)
            @sorcery_config.username_attribute_names.each do |attribute|
              @user = where(attribute => credential_regex(credentials[0])).first
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
