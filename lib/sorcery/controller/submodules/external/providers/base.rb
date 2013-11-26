module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          module Base
            module BaseClient
              @@providers = []

              def self.providers
                @@providers
              end

              def self.included(base)
                @@providers << base.to_s.gsub(/^.+::(\w+)Client/, '\1').downcase

                base.module_eval do
                  class << self
                    attr_accessor :original_callback_url
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
