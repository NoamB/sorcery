# HOWTO: Configure Sorcery

Sorcery is split up into modules, to enable easy/quick load/unload. So there are a few blocks of *stuff* you can configure. Here's a rundown of each item, and a description of what that item is for.

### The Core

You can amend the submodules array to define which parts of Sorcery you wish to use:

``Rails.application.config.sorcery.submodules = []``

Available options are:

      :user_activation        # to require users to confirm
      :http_basic_auth        # to use basic auth.
      :remember_me            # cookie based persistence
      :reset_password         # reset password token
      :session_timeout        # force a session to expire
      :brute_force_protection # prevents DOS login attacks
      :activity_logging       # keep notes on all user activity
      :external               # use external auth e.g. GitHub.

### Configuring the submodules

Within the ``Rails.application.config.sorcery.configure`` block, you can call any of these methods to set your choices. Each item is listed with their default option/type.

#### Core

* ``not_authenticated_action = :not_authenticated`` - this sets where the before_filter will call on discovery of an unauthenticated user accessing a protected resource.

* ``save_return_to_url = true`` - when a non logged in user tries to reach a protected resource, this indicates if the user should be sent back to that resource on successful login.

* ``cookie_domain = nil`` - useful for remember me, this sets the domain to set the cookie against.

* ``session_timeout = 3600`` - default session expiry window, in seconds.

* ``session_timeout_from_last_action = false`` - if we should reset the session based on activity. Think of this like, set_timeout = Time.now + session_timeout. 

#### HTTP Basic Auth

* ``controller_to_realm_map = {"application" => "Application"}`` - which realm to display for which controller, e.g. "admin" for your AdminController, or whatever.

#### Activity Logging 

* ``register_login_time = true`` - Whether to persist each time a user logs in, any/every time.

* ``register_logout_time = true`` - Whether to persist a user's logout time, any/every time.

* ``register_last_activity_time = true`` - Whether to persist the time of the last user action, any/every time.
 
#### External

* ``external_providers = []`` - These are the currently supported providers, as symbols (``[:twitter, :facebook, :github]``) 

* ``ca_file = ""`` - Path to a ca bundle if you want to change it. By default, it uses the haxx.se bundle which is derived from Mozilla's NSS Library.

These apply each for **twitter**, **facebook** and **github**, which are the current supported external authentication schemes. Using **github** as the example:

* ``github.key = ""`` - String, the authentication key for GitHub

* ``github.secret = ""`` - String, your secret key for the API

* ``github.callback_url = http://0.0.0.0:3000/oauth/callback?provider=github`` - The location to find the callback for this scheme
 
* ``github.user_info_mapping = {:email => "name"}`` - how to connect the external api's data with your own user data store.

### User

These are separate to the core config, and collect options about how to interact with the user model. They're typically specified **_within_** the config block, like so:

        config.user_config do |user|
           user.option = foo
           …
        end

#### Core

* ``username_attribute_names = [:username]`` - Which attributes to use to match for the username. Common examples include :username, :email…

* ``password_attribute_name = :password`` - Which key to use to refer to the password.

* ``downcase_username_before_authenticating = false`` - Downcase the username before trying to authenticate. Useful if you need to avoid doing case insensitive matching (e.g. for mongodb)
 
* ``email_attribute_name = :email`` - Which key to use for the email attribute.

* ``crypted_password_attribute_name = :crypted_password`` - Which key to use for the  encrypted password attribute.
 
* ``salt_join_token = ""`` - The pattern to use when joining the salt with the password.

* ``salt_attribute_name = :salt`` - Which key to use for the salt attribute.

* ``stretches = nil`` - How many times to apply the encryption routine to the password.

* ``encryption_key = nil`` - Encryption key used to encrypt reversible encryptions, such as AES256. **_WARNING_**: If used for user passwords, changing this key will leave existing passwords undecryptable (i.e. you won't be able to authenticate them.)

* ``custom_encryption_provider = nil`` - Use a custom class for providing encryption.

* ``encryption_algorithm = :bcrypt`` - The algorithm to use for encryption. See [here](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/model.rb#L267) for which algorithms are available.

* ``subclasses_inherit_config = false`` - Make this configuration available to subclasses. Useful for ActiveRecord STI or similar ancestor patterned code.

#### User Activation

* ``activation_state_attribute_name = :activation_state`` - The attribute name to hold the activation state (active/pending, typically)

* ``activation_token_attribute_name = :activation_token`` - The attribute name to store the activation code (sent by email)

* ``activation_token_expires_at_attribute_name = :activation_token_expires_at`` - Attribute for the token expiration.
 
* ``activation_token_expiration_period = nil`` - How many seconds before the token should expire. (nil for no expiry)

* ``user_activation_mailer = nil`` - **REQUIRED**. Your activation mailer class.

* ``activation_needed_email_method_name = :activation_needed_email`` - the 'activation needed' email method of your mailer class. Triggers when an account requires activation.

* ``activation_success_email_method_name = :activation_success_email`` - the 'activation success' email method of your mailer class. Triggered when an account is activated.

* ``prevent_non_active_users_to_login = true`` - Whether or not to force users to activate (confirm) their email first.

#### Password Reset

* ``reset_password_token_attribute_name = :reset_password_token`` - The attribute name to hold the reset token.

* ``reset_password_token_expires_at_attribute_name = :reset_password_token_expires_at`` - Same, for token expiry time

* ``reset_password_email_sent_at_attribute_name = :reset_password_email_sent_at`` - Same, for when the password reminder is sent.

* ``reset_password_mailer = nil`` - **REQUIRED**. Your reset password mailer class.

* ``reset_password_email_method_name = :reset_password_email`` - the method called to send a password reset.

* ``reset_password_expiration_period = nil`` - How many seconds to wait before the reset request expires. Nil disables.

* ``reset_password_time_between_emails = 5 * 60`` - Hammering protection. How long to wait before permitting another email to be sent. 

#### Brute Force Protection

* ``failed_logins_count_attribute_name = :failed_logins_count`` - The attribute name to store the number of failed logins in this session.

* ``lock_expires_at_attribute_name = :lock_expires_at`` - The attribute to hold the lock expiry time.

* ``consecutive_login_retries_amount_limit = 50`` - How many times logins may be attempted before locking out.

* ``login_lock_time_period = 60 * 60`` - How long the user should be banned, in seconds. 0 for permanent bans. 

#### Activity Logging

* ``last_login_at_attribute_name = :last_login_at`` - The attribute name for the last login time.

* ``last_logout_at_attribute_name = :last_logout_at`` - Same, for logout.

* ``last_activity_at_attribute_name = :last_activity_at`` - Same, for activity tracking.

* ``activity_timeout = 10 * 60`` - How long since the last activity is the user defined as logged out?

#### External

* ``authentications_class = nil`` - The class which holds various external provider data for this user (e.g. if you need to authenticate against a legacy system)

* ``authentications_user_id_attribute_name = :user_id`` - The user's identifier in the authentications class.

* ``provider_attribute_name = :provider`` - The provider's identifier in the authentications class.

* ``provider_uid_attribute_name = :uid`` - The external unique identifier as recognized by the authentications class.

### The Last Word

* ``config.user_class = "<%= model_class_name %>"`` - This can be left untouched, as it should be generated for you. This holds the name for the user class, and **MUST** go at the end of the initializer.




