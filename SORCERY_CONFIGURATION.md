# HOWTO: Configure Sorcery

Sorcery is split up into modules, to enable easy/quick load/unload. So there are a few blocks of *stuff* you can configure. Here's a rundown of each item, and a description of what that item is for.

### The Core

You can amend the submodules array to define which parts of Sorcery you wish to use:

```Rails.application.config.sorcery.submodules = []```

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

Within the ```Rails.application.config.sorcery.configure``` block, you can call any of these methods to set your choices. Each item is listed with their default.

#### Core

1. ``not_authenticated_action = :not_authenticated``



