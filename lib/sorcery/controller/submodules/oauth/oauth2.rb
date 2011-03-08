module Sorcery
  module Controller
    module Submodules
      module Oauth
        module Oauth2
          def authorize_url(args)
            client = ::OAuth2::Client.new(@key, @secret, :site => @site)
            client.web_server.authorize_url(:redirect_uri => @callback_url, :scope => 'email,offline_access')
          end
          
          def get_access_token(args)
            client = ::OAuth2::Client.new(@key, @secret, :site => @site)
            client.web_server.get_access_token(args[:code], :redirect_uri => @callback_url)
          end
        end
      end
    end
  end
end