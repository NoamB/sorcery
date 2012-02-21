# Hey There Developer!
# there are lots of things you are able to configure here and, to keep this
# file light and easy to read, but also to give you guys some solid
# documentation, You should visit the link below to learn more about what
# each config option does.
#
#  https://github.com/NoamB/sorcery/blob/master/SORCERY_CONFIGURATION.md
#
# The first thing you need to configure is which modules you need in your app.
# The default is nothing which will include only core features (password encryption, login/logout).
Rails.application.config.sorcery.submodules = []

# Here you can configure each submodule's features.
Rails.application.config.sorcery.configure do |config|
  # config.not_authenticated_action = :not_authenticated
  # config.save_return_to_url = true
  # config.cookie_domain = nil

  # -- session timeout --
  # config.session_timeout = 3600
  # config.session_timeout_from_last_action = false

  # -- http_basic_auth --
  # config.controller_to_realm_map = {"application" => "Application"}

  # -- activity logging --
  # config.register_login_time = true
  # config.register_logout_time = true
  # config.register_last_activity_time = true

  # -- external --
  # config.external_providers = []
  # config.ca_file = 'path/to/ca_file'

  # Twitter wil not accept any requests nor redirect uri containing localhost,
  # make sure you use 0.0.0.0:3000 to access your app in development
  #
  # config.twitter.key = "eYVNBjBDi33aa9GkA3w"
  # config.twitter.secret = "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8"
  # config.twitter.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=twitter"
  # config.twitter.user_info_mapping = {:email => "screen_name"}
  #
  # config.facebook.key = "34cebc81c08a521bc66e212f947d73ec"
  # config.facebook.secret = "5b458d179f61d4f036ee66a497ffbcd0"
  # config.facebook.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=facebook"
  # config.facebook.user_info_mapping = {:email => "name"}
  #
  # config.github.key = ""
  # config.github.secret = ""
  # config.github.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=github"
  # config.github.user_info_mapping = {:email => "name"}
  #
  # config.google.key = "491253340633.apps.googleusercontent.com"
  # config.google.secret = "4oE6kXqbL_LN-VGcGcg7qgdL"
  # config.google.callback_url = "http://0.0.0.0:3000/oauth/callback?provider=google"
  # config.google.user_info_mapping = {:email => "email", :username => "name"}
  #
  # To use liveid in development mode you have to replace mydomain.com with
  # a valid domain even in development. To use a valid domain in development
  # simply add your domain in your /etc/hosts file in front of 127.0.0.1
  #
  # config.liveid.key = ""
  # config.liveid.secret = ""
  # config.liveid.callback_url = "http://mydomain.com:3000/oauth/callback?provider=liveid"
  # config.liveid.user_info_mapping = {:username => "name"}

  # --- user config ---
  config.user_config do |user|
    # -- core --
    # user.username_attribute_names = [:username]
    # user.password_attribute_name = :password
    # user.email_attribute_name = :email
    # user.crypted_password_attribute_name =  :crypted_password

    # user.downcase_username_before_authenticating = false

    # user.salt_join_token = ""
    # user.salt_attribute_name = :salt
    # user.stretches = nil
    # user.encryption_key = nil
    # user.custom_encryption_provider = nil
    # user.encryption_algorithm = :bcrypt

    # user.subclasses_inherit_config = false

    # -- user_activation --
    # user.activation_state_attribute_name = :activation_state
    # user.activation_token_attribute_name = :activation_token
    # user.activation_token_expires_at_attribute_name = :activation_token_expires_at
    # user.activation_token_expiration_period =  nil
    # user.user_activation_mailer = nil
    # user.activation_needed_email_method_name = :activation_needed_email
    # user.activation_success_email_method_name = :activation_success_email
    # user.prevent_non_active_users_to_login = true

    # -- reset_password --
    # user.reset_password_token_attribute_name = :reset_password_token
    # user.reset_password_token_expires_at_attribute_name = :reset_password_token_expires_at
    # user.reset_password_email_sent_at_attribute_name = :reset_password_email_sent_at

    # user.reset_password_mailer = nil
    # user.reset_password_email_method_name = :reset_password_email

    # user.reset_password_expiration_period = nil
    # user.reset_password_time_between_emails = 5 * 60

    # -- brute_force_protection --
    # user.failed_logins_count_attribute_name = :failed_logins_count
    # user.lock_expires_at_attribute_name = :lock_expires_at

    # user.consecutive_login_retries_amount_limit = 50
    # user.login_lock_time_period = 60 * 60

    # -- activity logging --
    # user.last_login_at_attribute_name = :last_login_at
    # user.last_logout_at_attribute_name = :last_logout_at
    # user.last_activity_at_attribute_name = :last_activity_at
    # user.activity_timeout = 10 * 60


    # -- external --
    # user.authentications_class = nil
    # user.authentications_user_id_attribute_name = :user_id
    # user.provider_attribute_name = :provider
    # user.provider_uid_attribute_name = :uid

  end

  # This line must come after the 'user config' block.
  config.user_class = "<%= model_class_name %>"

end
