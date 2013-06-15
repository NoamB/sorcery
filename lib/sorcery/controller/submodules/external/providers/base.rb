module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          module Base
            module BaseClient
              def self.included(base)
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
