module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with Linkedin.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.linkedin'.
          # Via this new option you can configure Linkedin specific settings like your app's key and secret.
          #
          #   config.linkedin.key = <key>
          #   config.linkedin.secret = <secret>
          #   ...
          #
          module Linkedin
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :linkedin

                  def merge_linkedin_defaults!
                    @defaults.merge!(:@linkedin => LinkedinClient)
                  end
                end
                merge_linkedin_defaults!
                update!
              end
            end

            module LinkedinClient
              include Base::BaseClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :site,
                              :authorize_path,
                              :request_token_path,
                              :access_token_path,
                              :user_info_path,
                              :user_info_mapping,
                              :user_info_fields,
                              :access_permissions,
                              :state
                attr_reader   :access_token

                include Protocols::Oauth1

                # Override included get_consumer method to provide authorize_path
                def get_consumer
                  # Add access permissions to request token path
                  @configuration[:request_token_path] += "?scope=" + self.access_permissions.join('+') unless self.access_permissions.blank? or @configuration[:request_token_path].include? "?scope="
                  ::OAuth::Consumer.new(@key, @secret, @configuration)
                end

                def init
                  @configuration = {
                    site: "https://api.linkedin.com",
                    authorize_path: '/uas/oauth/authenticate',
                    request_token_path: '/uas/oauth/requestToken',
                    access_token_path: '/uas/oauth/accessToken'
                  }
                  @user_info_path = "/v1/people/~"
                end

                def get_user_hash(access_token)
                  user_hash = {}
                  fields = self.user_info_fields.join(',')
                  response = access_token.get("#{@user_info_path}:(#{fields})", 'x-li-format' => 'json')
                  user_hash[:user_info] = JSON.parse(response.body)
                  user_hash[:uid] = user_hash[:user_info]['id'].to_s
                  user_hash
                end

                def has_callback?
                  true
                end

                # calculates and returns the url to which the user should be redirected,
                # to get authenticated at the external provider's site.
                def login_url(params,session)
                  req_token = self.get_request_token
                  session[:request_token]         = req_token.token
                  session[:request_token_secret]  = req_token.secret
                  self.authorize_url({:request_token => req_token.token, :request_token_secret => req_token.secret})
                end

                # tries to login the user from access token
                def process_callback(params,session)
                  args = {}
                  args.merge!({:oauth_verifier => params[:oauth_verifier], :request_token => session[:request_token], :request_token_secret => session[:request_token_secret]})
                  args.merge!({:code => params[:code]}) if params[:code]
                  return self.get_access_token(args)
                end

              end
              init
            end
          end
        end
      end
    end
  end
end
