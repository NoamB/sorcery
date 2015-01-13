# Changelog

## 1.0 (not released yet)

* Adapters (Mongoid, MongoMapper, DataMapper) are now separated from the core Sorcery repo and moved under `sorcery-rails` organization. Special thanks to @juike!

## 0.9.0

* Sending emails works with Rails 4.2 (thanks to @wooly)
* Added `valid_password?` method
* Added support for JIRA OAuth (thanks to @camilasan)
* Added support for Heroku OAuth (thanks to @tyrauber)
* Added support for Salesforce OAuth (thanks to @supremebeing7)
* Added support for Mongoid 4
* Fixed issues with empty passwords (thanks to @Borzik)
* `find_by_provider_and_uid` method was replaced with `find_by_oauth_credentials`
* Sorcery::VERSION constant was added to allow easy version check
* `@user.setup_activation` method was made to be public (thanks @iTakeshi)
* `current_users` method is deprecated
* Fetching email from VK auth, thanks to @makaroni4
* Add logged_in? method to test_helpers (thanks to @oriolbcn)
* #locked? method is now public API (thanks @rogercampos)
* Introduces a new User instance method `generate_reset_password_token` to generate a new reset password token without sending an email (thanks to @tbuehl)

## 0.8.6

* `current_user` returns `nil` instead of `false` if there's no user loggd in (#493)
* MongoMapper adapter does not override `save!` method anymore. However due to ORM's lack of support for `validate: false` in `save!`, the combination of `validate: false` and `raise_on_failure: true` is not possible in MongoMapper. The errors will not be raised in this situation. (#151)
* Fixed rename warnings for bcrypt-ruby
* The way Sorcery adapters are included has been changed due to problem with multiple `included` blocks error in `ActiveSupport::Concern` class (#527)
* Session timeout works with new cookie serializer introduced in Rails 4.1
* Rails 4.1 compatibility bugs were fixed, this version is fully supported (#538)
* VK providers now supports `scope` option
* Support for DataMapper added
* Helpers for integration tests were added
* Fixed problems with special characters in user login attributes (MongoMapper & Mongoid)
* Fixed remaining `password_confirmation` value - it is now cleared just like `password`

## 0.8.5
* Fixed add_provider_to_user with CamelCased authentications_class model (#382)
* Fixed unlock_token_mailer_disabled to only disable automatic mailing (#467)
* Make send_email_* methods easier to overwrite (#473)
* Don't add `:username` field for User. Config option `username_attribute_names` is now `:email` by default instead of `:username`.

  If you're using `username` as main field for users to login, you'll need to tune your Sorcery config:

    ```ruby
    config.user_config do |user|
      # ...
      user.username_attribute_names = [:username]
    end
    ```
* `rails generate sorcery:install` now works inside Rails engine

## 0.8.4

  * Few security fixes in `external` module

## 0.8.3 (yanked because of bad Jeweler release)

## 0.8.2

* Activity logging feature has a new column called `last_login_from_ip_address` (string type). If you use ActiveRecord, you will have to add this column to DB ([#465](https://github.com/NoamB/sorcery/issues/465))

## 0.8.1
<!-- TO BE WRITTEN -->

## 0.8.0
<!-- TO BE WRITTEN -->

## 0.7.13
<!-- TO BE WRITTEN -->

## 0.7.12
<!-- TO BE WRITTEN -->

## 0.7.11
<!-- TO BE WRITTEN -->

## 0.7.10
<!-- TO BE WRITTEN -->

## 0.7.9
<!-- TO BE WRITTEN -->

## 0.7.8
<!-- TO BE WRITTEN -->

## 0.7.7
<!-- TO BE WRITTEN -->

## 0.7.6
<!-- TO BE WRITTEN -->

## 0.7.5
<!-- TO BE WRITTEN -->

## 0.7.1-0.7.4

* Fixed a bug in the new generator
* Many bugfixes
* MongoMapper added to supported ORMs list, thanks @kbighorse
* Sinatra support discontinued!
* New generator contributed by @ahazem
* Cookie domain setting contributed by @Highcode


## 0.7.0

* Many bugfixes
* Added default SSL certificate for oauth2
* Added multi-username ability
* Security fixes (CSRF, cookie digesting)
* Added auto_login(user) to the API
* Updated gem versions of oauth(1/2)
* Added logged_in? as a view helper
* Github provider added to external submodule


## 0.6.1

Gemfile versions updated due to public demand.
(bcrypt 3.0.0 and oauth2 0.4.1)


## 0.6.0

Fixes issues with external user_hash not including some fields, and an issue with User model not loaded when user_class is called. Now config.user_class should be a string or a symbol.

Improved specs.

## 0.5.3

Fixed #9
Fixed hardcoded method names in remember_me submodule.
Improved specs.

## 0.5.21

Fixed typo in initializer - MUST be "config.user_class = User"

## 0.5.2

Fixed #3 and #4 - Modular Sinatra apps work now, and User model isn't cached in development mode.

## 0.5.1

Fixed bug in reset_password - after reset can't login due to bad salt creation. Affected only Mongoid.

## 0.5.0

Added support for Mongoid! (still buggy and not recommended for serious use)

'reset_password!(:password => new_password)' changed into 'change_password!(new_password)'

## 0.4.2

Added test helpers for Rails 3 & Sinatra.

## 0.4.1

Fixing Rails app name in initializer.

## 0.4.0

Changed the way Sorcery is configured.
Now inside the model only add:

```
authenticates_with_sorcery!
```

In the controller no code is needed! All configuration is done in an initializer.
Added a rake task to create it.

```
rake sorcery:bootstrap
```

## 0.3.1

Renamed "oauth" module to "external" and made API prettier.
```
auth_at_provider(provider) => login_at(provider)
login_from_access_token(provider) => login_from(provider)
create_from_provider!(provider) => create_from(provider)
```

## 0.3.0

Added Sinatra support!


Added Rails 3 generator for migrations


## 0.2.1

Fixed bug with OAuth submodule - oauth gems were not required properly in gem.


Fixed bug with OAuth submodule - Authentications class was not passed between model and controller in all cases resulting in Nil exception.


## 0.2.0

Added OAuth submodule.

### OAuth:
* OAuth1 and OAuth2 support (currently twitter & facebook)
* configurable db field names and authentications table.

Some bug fixes: 'return_to' feature, brute force permanent ban.


## 0.1.4

Added activity logging submodule.


### Activity Logging:
* automatic logging of last login, last logout and last activity time.
* an easy method of collecting the list of currently logged in users.
* configurable timeout by which to decide whether to include a user in the list of logged in users.


Fixed bug in basic_auth - it didn't set the session[:user_id] on successful login and tried to relogin from basic_auth on every action.


Added Reset Password hammering protection and updated the API.


Totally rewritten Brute Force Protection submodule.


## 0.1.3

Added support for Basic HTTP Auth.

## 0.1.2

Separated mailers between user_activation and password_reset and updated readme.

## 0.1.1

Fixed bug with BCrypt not being used properly by the lib and thus not working for authentication.

## 0.1.0

### Core Features:
* login/logout, optional redirect on login to where the user tried to reach before, configurable redirect for non-logged-in users.
* password encryption, algorithms: bcrypt(default), md5, sha1, sha256, sha512, aes256, custom(yours!), none. Configurable stretches and salt.
* configurable attribute names for username, password and email.
### User Activation:
* User activation by email with optional success email.
* configurable attribute names.
* configurable mailer.
* Optionally prevent active users to login.
### Password Reset:
* Reset password with email verification.
* configurable mailer, method name, and attribute name.
### Remember Me:
* Remember me with configurable expiration.
* configurable attribute names.
## Session Timeout:
* Configurable session timeout.
* Optionally session timeout will be calculated from last user action.
### Brute Force Protection:
* Brute force login hammering protection.
* configurable logins before ban, logins within time period before ban, ban time and ban action.
