require 'oauth2'
module Sorcery
  module Controller
    module Submodules
      module External
        module Protocols
          module Oauth2
            def self.included(base)
              base.send(:include, InstanceMethods)
              Config.module_eval do
                class << self
                  attr_accessor :ca_file                     # how long in seconds to keep the session alive.
                                
                  def merge_oauth2_defaults!
                    @defaults.merge!(:@ca_file => File.join(File.expand_path(File.dirname(__FILE__)), 
    'certs/ca-bundle.crt'))
                  end
                end
                merge_oauth2_defaults!
              end
            end
            
            def oauth_version
              "2.0"
            end
          
            def authorize_url(*args)
              client = ::OAuth2::Client.new(@key, @secret, :site => @site, :ssl => { :ca_file => Config.ca_file })
              client.web_server.authorize_url(:redirect_uri => @callback_url, :scope => @scope)
            end
          
            def get_access_token(args)
              client = ::OAuth2::Client.new(@key, @secret, :site => @site, :ssl => { :ca_file => Config.ca_file })
		          client.web_server.get_access_token(args[:code], :redirect_uri => @callback_url)
            end
          end
        end
      end
    end
  end
end
