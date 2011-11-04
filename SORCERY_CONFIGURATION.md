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

These are seperate to the core config, and collect options about how to interact with the user model. They're typically specified **_within_** the config block, like so:

        config.user_config do |user|
           ...
        end

#### Core

* ``username_attribute_names = [:username]`` - Which attributes to use to match for the username. Common examples include :username, :email…

* ``password_attribute_name = :password`` - Which key to use to refer to the password.

* ```` - 
* ```` - 
* ```` - 
* ```` - 



