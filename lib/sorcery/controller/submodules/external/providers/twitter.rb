module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with Twitter.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.twitter'.
          # Via this new option you can configure Twitter specific settings like your app's key and secret.
          #
          #   config.twitter.key = <key>
          #   config.twitter.secret = <secret>
          #   ...
          #
          module Twitter
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :twitter
                  # def twitter(&blk) # allows block syntax.
                  #   yield @twitter
                  # end

                  def merge_twitter_defaults!
                    @defaults.merge!(:@twitter => TwitterClient)
                  end
                end
                merge_twitter_defaults!
                update!
              end
            end

            module TwitterClient
              include Base::BaseClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :site,
                              :user_info_path,
                              :user_info_mapping,
                              :state
                attr_reader   :access_token

                include Protocols::Oauth1

				        # Override included get_consumer method to provide authorize_path
				        def get_consumer
                  ::OAuth::Consumer.new(@key, @secret, :site => @site, :authorize_path => "/oauth/authenticate")
                end

                def init
                  @site           = "https://api.twitter.com"
                  @user_info_path = "/1.1/account/verify_credentials.json"
                  @user_info_mapping = {}
                end

                def get_user_hash(access_token)
                  user_hash = {}
                  response = access_token.get(@user_info_path)
                  user_hash[:user_info] = JSON.parse(response.body)
                  user_hash[:uid] = user_hash[:user_info]['id'].to_s
                  user_hash
                end

                def has_callback?
                  true
                end

                # calculates and returns the url to which the user should be redirected,
                # to get authenticated at the external provider's site.
                def login_url(params, session)
                  req_token = self.get_request_token
                  session[:request_token]         = req_token.token
                  session[:request_token_secret]  = req_token.secret
                  self.authorize_url({:request_token => req_token.token, :request_token_secret => req_token.secret})
                end

                # tries to login the user from access token
                def process_callback(params, session)
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
