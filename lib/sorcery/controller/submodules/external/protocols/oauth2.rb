require 'oauth2'
module Sorcery
  module Controller
    module Submodules
      module External
        module Protocols
          module Oauth2
            def oauth_version
              "2.0"
            end
          
            def authorize_url(*args)
              client = ::OAuth2::Client.new(@key, @secret, :site => @site)
              client.web_server.authorize_url(:redirect_uri => @callback_url, :scope => @scope, :ssl => { :ca_file => File.join(File.expand_path(File.dirname(__FILE__)), 'certs/ca-bundle.crt')})
            end
          
            def get_access_token(args)
              client.web_server.authorize_url(:redirect_uri => @callback_url, :scope => @scope, :ssl => { :ca_file => File.join(File.expand_path(File.dirname(__FILE__)), 'certs/ca-bundle.crt')})
              client.web_server.get_access_token(args[:code], :redirect_uri => @callback_url)
            end
          end
        end
      end
    end
  end
end
