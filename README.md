[![Build Status](https://travis-ci.org/NoamB/sorcery.svg?branch=master)](https://travis-ci.org/NoamB/sorcery)
[![Code Climate](https://codeclimate.com/github/NoamB/sorcery.png)](https://codeclimate.com/github/NoamB/sorcery)
[![Inline docs](http://inch-ci.org/github/NoamB/sorcery.png?branch=master)](http://inch-ci.org/github/NoamB/sorcery)

# sorcery
Magical Authentication for Rails 3 and 4. Supports ActiveRecord,
DataMapper, Mongoid and MongoMapper.

Inspired by restful_authentication, Authlogic and Devise. Crypto code taken
almost unchanged from Authlogic. OAuth code inspired by OmniAuth and Ryan
Bates's railscasts about it.

**What's happening now?** We are working on 1.0 version, which will include some API-breaking changes. It should be released about April 2015.
Until then we'll continue releasing `0.9.x` version with bug fixed.

**Rails 4 status:** [Sorcery 0.9.0](http://rubygems.org/gems/sorcery/versions/0.9.0) is fully tested and ready for Rails 4.0, 4.1 and 4.2.
**Mongoid status:** Version 0.9.0 works with Mongoid 4.

https://github.com/NoamB/sorcery/wiki/Simple-Password-Authentication

## Philosophy

Sorcery is a stripped-down, bare-bones authentication library, with which you
can write your own authentication flow. It was built with a few goals in mind:

*   Less is more - less than 20 public methods to remember for the entire
    feature-set make the lib easy to 'get'.
*   No built-in or generated code - use the library's methods inside *your
    own* MVC structures, and don't fight to fix someone else's.
*   Magic yes, Voodoo no - the lib should be easy to hack for most developers.
*   Configuration over Confusion - Centralized (1 file), Simple & short
    configuration as possible, not drowning in syntactic sugar.
*   Keep MVC cleanly separated - DB is for models, sessions are for
    controllers. Models stay unaware of sessions.


Hopefully, I've achieved this. If not, let me know.

## Useful Links

[Documentation](http://rubydoc.info/gems/sorcery) |
[Railscast](http://railscasts.com/episodes/283-authentication-with-sorcery) | [Simple tutorial](https://github.com/NoamB/sorcery/wiki/Simple-Password-Authentication) | [Example Rails 3 app](https://github.com/NoamB/sorcery-example-app)

Check out the tutorials in the [Wiki](https://github.com/NoamB/sorcery/wiki) for more!

## API Summary

Below is a summary of the library methods. Most method names are self
explaining and the rest are commented:


### core
```ruby
require_login # this is a before filter
login(email, password, remember_me = false)
auto_login(user)# login without credentials
logout
logged_in?      # available to view
current_user    # available to view
redirect_back_or_to # used when a user tries to access a page while logged out, is asked to login, and we want to return him back to the page he originally wanted.
@user.external? # external users, such as facebook/twitter etc.
User.authenticates_with_sorcery!
```

### http basic auth
```ruby
require_login_from_http_basic # this is a before filter
```

### external
```ruby
login_at(provider) # sends the user to an external service (twitter etc.) to authenticate.
login_from(provider) # tries to login from the external provider's callback.
create_from(provider) # create the user in the local app db.
```

### remember me
```ruby
auto_login(user, should_remember=false)  # login without credentials, optional remember_me
remember_me!
forget_me!
```

### reset password
```ruby
User.load_from_reset_password_token(token)
@user.generate_reset_password_token! # if you want to send the email by youself
@user.deliver_reset_password_instructions! # generates the token and sends the email
@user.change_password!(new_password)
```

### user activation
```ruby
User.load_from_activation_token(token)
@user.setup_activation
@user.activate!
```

Please see the tutorials in the github wiki for detailed usage information.

## Installation

If using bundler, first add 'sorcery' to your Gemfile:

```ruby
gem "sorcery"
```

And run

```ruby
bundle install
```

Otherwise simply

```ruby
gem install sorcery
```

## Rails configuration

```bash
rails generate sorcery:install
```

This will generate the core migration file, the initializer file and the
'User' model class.

```bash
rails generate sorcery:install remember_me reset_password
```

This will generate the migrations files for remember_me and reset_password
submodules and will create the initializer file (and add submodules to it),
and create the 'User' model class.

```bash
rails generate sorcery:install --model Person
```

This will generate the core migration file, the initializer and change the
model class (in the initializer and migration files) to the class 'Person'
(and its pluralized version, 'people')

```bash
rails generate sorcery:install http_basic_auth external remember_me --only-submodules
```

This will generate only the migration files for the specified submodules and
will add them to the initializer file.

Inside the initializer, the comments will tell you what each setting does.

## DelayedJob Integration

By default emails are sent synchronously. You can send them asynchronously by
using the [delayed_job gem](https://github.com/collectiveidea/delayed_job).

After implementing the `delayed_job` into your project add the code below at
the end of the `config/initializers/sorcery.rb` file. After that all emails
will be sent asynchronously.

```ruby
module Sorcery
  module Model
    module InstanceMethods
      def generic_send_email(method, mailer)
        config = sorcery_config
        mail = config.send(mailer).delay.send(config.send(method), self)
      end
    end
  end
end
```

Sidekiq and Resque integrations are coming soon.

## Single Table Inheritance (STI) Support
STI is supported via a single setting in config/initializers/sorcery.rb.

## Full Features List by module

**Core** (see [lib/sorcery/model.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/model.rb) and
[lib/sorcery/controller.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/controller.rb)):

*   login/logout, optional return user to requested url on login, configurable
    redirect for non-logged-in users.
*   password encryption, algorithms: bcrypt(default), md5, sha1, sha256,
    sha512, aes256, custom(yours!), none. Configurable stretches and salt.
*   configurable attribute names for username, password and email.
*   allow multiple fields to serve as username.


**User Activation** (see [lib/sorcery/model/submodules/user_activation.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/model/submodules/user_activation.rb)):

*   User activation by email with optional success email.
*   configurable attribute names.
*   configurable mailer, method name, and attribute name.
*   configurable temporary token expiration.
*   Optionally prevent non-active users to login.


**Reset Password** (see [lib/sorcery/model/submodules/reset_password.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/model/submodules/reset_password.rb)):

*   Reset password with email verification.
*   configurable mailer, method name, and attribute name.
*   configurable temporary token expiration.
*   configurable time between emails (hammering protection).


**Remember Me** (see [lib/sorcery/model/submodules/remember_me.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/model/submodules/remember_me.rb)):

*   Remember me with configurable expiration.
*   configurable attribute names.


**Session Timeout** (see [lib/sorcery/controller/submodules/session_timeout.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/controller/submodules/session_timeout.rb)):

*   Configurable session timeout.
*   Optionally session timeout will be calculated from last user action.


**Brute Force Protection** (see [lib/sorcery/model/submodules/brute_force_protection.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/model/submodules/brute_force_protection.rb)):

*   Brute force login hammering protection.
*   configurable logins before lock and lock duration.


**Basic HTTP Authentication** (see [lib/sorcery/controller/submodules/http_basic_auth.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/controller/submodules/http_basic_auth.rb)):

*   A before filter for requesting authentication with HTTP Basic.
*   automatic login from HTTP Basic.
*   automatic login is disabled if session key changed.


**Activity Logging** (see [lib/sorcery/model/submodules/activity_logging.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/model/submodules/activity_logging.rb)):

*   automatic logging of last login, last logout, last activity time and IP
    address for last login.
*   an easy method of collecting the list of currently logged in users.
*   configurable timeout by which to decide whether to include a user in the
    list of logged in users.


**External** (see [lib/sorcery/controller/submodules/external.rb](https://github.com/NoamB/sorcery/blob/master/lib/sorcery/controller/submodules/external.rb)):

*   OAuth1 and OAuth2 support (currently: Twitter, Facebook, Github, Google, Heroku,
    LinkedIn, VK, LiveID, Xing, and Salesforce)
*   configurable db field names and authentications table.


## Next Planned Features

I've got some thoughts which include (unordered):

*   Passing a block to encrypt, allowing the developer to define his own mix
    of salting and encrypting
*   Forgot username, maybe as part of the reset_password module
*   Scoping logins (to a subdomain or another arbitrary field)
*   Allowing storing the salt and crypted password in the same DB field for
    extra security
*   Other reset password strategies (security questions?)
*   Other brute force protection strategies (captcha)


Have an idea? Let me know, and it might get into the gem!

## Backward compatibility

While the lib is young and evolving fast I'm breaking backward compatibility
quite often. I'm constantly finding better ways to do things and throwing away
old ways. To let you know when things are changing in a non-compatible way,
I'm bumping the minor version of the gem. The patch version changes are
backward compatible.

In short, an app that works with x.3.1 should be able to upgrade to x.3.2 with
no code changes. The same cannot be said about upgrading to x.4.0 and above,
however.

## DataMapper Support

Important notes:

*   Expected to work with DM adapters: dm-mysql-adapter,
    dm-redis-adapter.
*   Submodules DM adapter dependent: activity_logging (dm-mysql-adapter)
*   Usage: include DataMapper::Resource in user model, follow sorcery
    instructions (remember to add property id, validators and accessor
attributes such as password and password_confirmation)
*   Option downcase__username_before_authenticating and dm-mysql,
    http://datamapper.lighthouseapp.com/projects/20609/tickets/1105-add-support-for-definingchanging-default-collation

## Upgrading

Important notes while upgrading:

*   If you are upgrading from <= **0.8.6** and you use Sorcery model methods in your app,
    you might need to change them from `user.method` to `user.sorcery_adapter.method` and from
    `User.method` to `User.sorcery_adapter_method`

*   If you are upgrading from <= **0.8.5** and you're using Sorcery test helpers,
    you need to change the way you include them to following code:

    ```ruby
    RSpec.configure do |config|
      config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
      config.include Sorcery::TestHelpers::Rails::Integration, type: :feature
    end
    ```

*   If are upgrading to **0.8.2** and use activity_logging feature with
    ActiveRecord, you will have to add a new column
    `last_login_from_ip_address`
    [#465](https://github.com/NoamB/sorcery/issues/465)
*   Sinatra support existed until **v0.7.0** (including), but was dropped
    later due to being a maintenance nightmare.
*   If upgrading from <= **0.6.1 to >= **0.7.0** you need to change
    'username
    _attribute_name' to 'username_attribute_names' in initializer.
*   If upgrading from <= **v0.5.1** to >= **v0.5.2** you need to explicitly
    set your user_class model in the initializer file.

    ```ruby
    # This line must come after the 'user config' block.
    config.user_class = User
    ```


## Contributing to sorcery

Your feedback is very welcome and will make this gem much much better for you,
me and everyone else. Besides feedback on code, features, suggestions and bug
reports, you may want to actually make an impact on the code. For this:

*   Fork it.
*   Fix it.
*   Test it.
*   Commit it.
*   Send me a pull request so I'll... Pull it.


If you feel sorcery has made your life easier, and you would like to express
your thanks via a donation, my paypal email is in the contact details.

## Contact

Feel free to ask questions using these contact details:

#### Noam Ben-Ari

email: nbenari@gmail.com ( also for paypal )

twitter: @nbenari

#### Kir Shatrov

email: shatrov@me.com

twitter: @Kiiiir

#### Grzegorz Witek

email: arnvald.to@gmail.com

twitter: @arnvald

## Copyright

Copyright (c) 2010-2014 Noam Ben Ari (nbenari@gmail.com). See LICENSE.txt for
further details.
