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

            def authorize_url(options = {})
              client = build_client(options)
              client.web_server.authorize_url(
                :redirect_uri => @callback_url,
                :scope => @scope
              )
            end

            def get_access_token(args, options = {})
              client = build_client(options)
              client.web_server.get_access_token(
                args[:code],
                :redirect_uri => @callback_url
              )
            end

            def build_client(options = {})
              defaults = {
                :site => @site,
                :ssl => { :ca_file => Config.ca_file }
              }
              ::OAuth2::Client.new(
                @key,
                @secret,
                defaults.merge!(options)
              )
            end
          end
        end
      end
    end
  end
end
