module Sorcery
  module Providers
    # This class adds support for OAuth with Instagram.com.

    class Instagram < Base

      include Protocols::Oauth2


      attr_accessor :access_permissions, :token_url,
                    :authorization_path, :user_info_path,
                    :scope, :user_info_fields


      def initialize
        @site           = 'https://api.instagram.com'
        @token_url = '/oauth/access_token'
        @authorization_path = '/oauth/authorize/'
        @user_info_path = '/v1/users/self'
        super
      end

      # provider implements method to build Oauth client
      def login_url(params, session)
        authorize_url
      end


      # @override of Base#authorize_url
      def authorize_url(opts={})
        @scope = build_access_scope!
        super(opts.merge(:token_url => @token_url))
      end

      # pass oauth2 param `code` provided by instgrm server
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end
        get_access_token(args, token_url: @token_url,
          client_id: @key, client_secret: @secret)
      end


      # see `user_info_mapping` in config/initializer,
      # given `user_info_mapping` to specify
      #   {:db_attribute_name => 'instagram_attr_name'}
      # so that Sorcery can build AR model from attr names
      #
      # NOTE: instead of just getting the user info
      # from the access_token (which already returns them),
      # testing strategy relies on querying user_info_path
      def get_user_hash(access_token)
        call_api_params = {
          :access_token => access_token.token,
          :client_id => access_token[:client_id]
        }
        response = access_token.get(
          "#{user_info_path}?#{call_api_params.to_param}"
        )


        _user_attrs = Hash.new
        _user_attrs[:user_info] = JSON.parse(response.body)['data']
        _user_attrs[:uid] = _user_attrs[:user_info]['id']
        _user_attrs
      end


      private

        # build access scope attribute for instagram
        # e.g. whether to access for `likes` or just basic
        def build_access_scope!
          valid = /\A(basic|comments|relationships|likes)$/

          if !access_permissions.present?
            _scopes = ["basic"]
          elsif access_permissions.kind_of?(Array)
            _scopes = access_permissions
                        .map(&:to_s)
                        .grep(valid)
          elsif access_permissions.kind_of?(String)
            _scopes = access_permissions
                       .split(/\W+/)
                       .grep(valid)
          end

          # basic IS required
          # b/c instagram fails on blank values
          # and requires `basic` for any additional scope
          _scopes.push('basic')

          _scopes.uniq.join(' ')

        end

    end

  end

end