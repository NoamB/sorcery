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
              client.auth_code.authorize_url(
                :redirect_uri => @callback_url,
                :scope => @scope,
                :display => @display
              )
            end

            def get_access_token(args, options = {})
              raise ArgumentError, "either a `code` or an `access token` is necessary to build an Oauth2 AccessToken" if args[:code].nil? && args[:access_token].nil?

              client = build_client(options)

              if args[:access_token]
                hash = args
                hash.merge!({:mode => options[:mode]}) if options[:mode]
                hash.merge!({:param_name => options[:param_name]}) if options[:param_name]
                ::OAuth2::AccessToken.from_hash(client, hash)
              else
                client.auth_code.get_token(
                  args[:code],
                  { :redirect_uri => @callback_url, :parse => options.delete(:parse) }, options
                )
              end
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
