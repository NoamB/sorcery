# Be sure to restart your server when you modify this file.

AppRoot::Application.config.session_store :cookie_store, :key => '_app_root_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# AppRoot::Application.config.session_store :active_record_store

if AppRoot::Application.config.respond_to?(:secret_key_base=)
  AppRoot::Application.config.secret_key_base = "foobar"
end