# -*- encoding: utf-8 -*-
# stub: sorcery 0.9.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sorcery"
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Noam Ben Ari", "Kir Shatrov", "Grzegorz Witek"]
  s.date = "2016-10-03"
  s.description = "Provides common authentication needs such as signing in/out, activating by email and resetting password."
  s.email = "nbenari@gmail.com"
  s.files = [".document", ".gitignore", ".rspec", ".travis.yml", "CHANGELOG.md", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "gemfiles/active_record-rails40.gemfile", "gemfiles/active_record-rails41.gemfile", "gemfiles/active_record-rails42.gemfile", "lib/generators/sorcery/USAGE", "lib/generators/sorcery/helpers.rb", "lib/generators/sorcery/install_generator.rb", "lib/generators/sorcery/templates/initializer.rb", "lib/generators/sorcery/templates/migration/activity_logging.rb", "lib/generators/sorcery/templates/migration/brute_force_protection.rb", "lib/generators/sorcery/templates/migration/core.rb", "lib/generators/sorcery/templates/migration/external.rb", "lib/generators/sorcery/templates/migration/remember_me.rb", "lib/generators/sorcery/templates/migration/reset_password.rb", "lib/generators/sorcery/templates/migration/user_activation.rb", "lib/sorcery.rb", "lib/sorcery/adapters/active_record_adapter.rb", "lib/sorcery/adapters/base_adapter.rb", "lib/sorcery/controller.rb", "lib/sorcery/controller/config.rb", "lib/sorcery/controller/submodules/activity_logging.rb", "lib/sorcery/controller/submodules/brute_force_protection.rb", "lib/sorcery/controller/submodules/external.rb", "lib/sorcery/controller/submodules/http_basic_auth.rb", "lib/sorcery/controller/submodules/remember_me.rb", "lib/sorcery/controller/submodules/session_timeout.rb", "lib/sorcery/crypto_providers/aes256.rb", "lib/sorcery/crypto_providers/bcrypt.rb", "lib/sorcery/crypto_providers/common.rb", "lib/sorcery/crypto_providers/md5.rb", "lib/sorcery/crypto_providers/sha1.rb", "lib/sorcery/crypto_providers/sha256.rb", "lib/sorcery/crypto_providers/sha512.rb", "lib/sorcery/engine.rb", "lib/sorcery/model.rb", "lib/sorcery/model/config.rb", "lib/sorcery/model/submodules/activity_logging.rb", "lib/sorcery/model/submodules/brute_force_protection.rb", "lib/sorcery/model/submodules/external.rb", "lib/sorcery/model/submodules/remember_me.rb", "lib/sorcery/model/submodules/reset_password.rb", "lib/sorcery/model/submodules/user_activation.rb", "lib/sorcery/model/temporary_token.rb", "lib/sorcery/protocols/certs/ca-bundle.crt", "lib/sorcery/protocols/oauth.rb", "lib/sorcery/protocols/oauth2.rb", "lib/sorcery/providers/base.rb", "lib/sorcery/providers/facebook.rb", "lib/sorcery/providers/github.rb", "lib/sorcery/providers/google.rb", "lib/sorcery/providers/heroku.rb", "lib/sorcery/providers/jira.rb", "lib/sorcery/providers/linkedin.rb", "lib/sorcery/providers/liveid.rb", "lib/sorcery/providers/paypal.rb", "lib/sorcery/providers/salesforce.rb", "lib/sorcery/providers/slack.rb", "lib/sorcery/providers/twitter.rb", "lib/sorcery/providers/vk.rb", "lib/sorcery/providers/xing.rb", "lib/sorcery/test_helpers/internal.rb", "lib/sorcery/test_helpers/internal/rails.rb", "lib/sorcery/test_helpers/rails/controller.rb", "lib/sorcery/test_helpers/rails/integration.rb", "lib/sorcery/version.rb", "sorcery.gemspec", "spec/active_record/user_activation_spec.rb", "spec/active_record/user_activity_logging_spec.rb", "spec/active_record/user_brute_force_protection_spec.rb", "spec/active_record/user_oauth_spec.rb", "spec/active_record/user_remember_me_spec.rb", "spec/active_record/user_reset_password_spec.rb", "spec/active_record/user_spec.rb", "spec/controllers/controller_activity_logging_spec.rb", "spec/controllers/controller_brute_force_protection_spec.rb", "spec/controllers/controller_http_basic_auth_spec.rb", "spec/controllers/controller_oauth2_spec.rb", "spec/controllers/controller_oauth_spec.rb", "spec/controllers/controller_remember_me_spec.rb", "spec/controllers/controller_session_timeout_spec.rb", "spec/controllers/controller_spec.rb", "spec/orm/active_record.rb", "spec/rails_app/app/active_record/authentication.rb", "spec/rails_app/app/active_record/user.rb", "spec/rails_app/app/active_record/user_provider.rb", "spec/rails_app/app/controllers/sorcery_controller.rb", "spec/rails_app/app/helpers/application_helper.rb", "spec/rails_app/app/mailers/sorcery_mailer.rb", "spec/rails_app/app/views/application/index.html.erb", "spec/rails_app/app/views/layouts/application.html.erb", "spec/rails_app/app/views/sorcery_mailer/activation_email.html.erb", "spec/rails_app/app/views/sorcery_mailer/activation_email.text.erb", "spec/rails_app/app/views/sorcery_mailer/activation_needed_email.html.erb", "spec/rails_app/app/views/sorcery_mailer/activation_success_email.html.erb", "spec/rails_app/app/views/sorcery_mailer/activation_success_email.text.erb", "spec/rails_app/app/views/sorcery_mailer/reset_password_email.html.erb", "spec/rails_app/app/views/sorcery_mailer/reset_password_email.text.erb", "spec/rails_app/app/views/sorcery_mailer/send_unlock_token_email.text.erb", "spec/rails_app/config.ru", "spec/rails_app/config/application.rb", "spec/rails_app/config/boot.rb", "spec/rails_app/config/database.yml", "spec/rails_app/config/environment.rb", "spec/rails_app/config/environments/test.rb", "spec/rails_app/config/initializers/backtrace_silencers.rb", "spec/rails_app/config/initializers/inflections.rb", "spec/rails_app/config/initializers/mime_types.rb", "spec/rails_app/config/initializers/secret_token.rb", "spec/rails_app/config/initializers/session_store.rb", "spec/rails_app/config/locales/en.yml", "spec/rails_app/config/routes.rb", "spec/rails_app/db/migrate/activation/20101224223622_add_activation_to_users.rb", "spec/rails_app/db/migrate/activity_logging/20101224223624_add_activity_logging_to_users.rb", "spec/rails_app/db/migrate/brute_force_protection/20101224223626_add_brute_force_protection_to_users.rb", "spec/rails_app/db/migrate/core/20101224223620_create_users.rb", "spec/rails_app/db/migrate/external/20101224223628_create_authentications_and_user_providers.rb", "spec/rails_app/db/migrate/remember_me/20101224223623_add_remember_me_token_to_users.rb", "spec/rails_app/db/migrate/reset_password/20101224223622_add_reset_password_to_users.rb", "spec/rails_app/db/schema.rb", "spec/rails_app/db/seeds.rb", "spec/shared_examples/user_activation_shared_examples.rb", "spec/shared_examples/user_activity_logging_shared_examples.rb", "spec/shared_examples/user_brute_force_protection_shared_examples.rb", "spec/shared_examples/user_oauth_shared_examples.rb", "spec/shared_examples/user_remember_me_shared_examples.rb", "spec/shared_examples/user_reset_password_shared_examples.rb", "spec/shared_examples/user_shared_examples.rb", "spec/sorcery_crypto_providers_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/NoamB/sorcery"
  s.licenses = ["MIT"]
  s.post_install_message = "As of version 1.0 oauth/oauth2 won't be automatically bundled\nyou need to add those dependencies to your Gemfile"
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.5.1"
  s.summary = "Magical authentication for Rails 3 & 4 applications"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<oauth>, [">= 0.4.4", "~> 0.4"])
      s.add_runtime_dependency(%q<oauth2>, [">= 0.8.0"])
      s.add_runtime_dependency(%q<bcrypt>, ["~> 3.1"])
      s.add_development_dependency(%q<abstract>, [">= 1.0.0"])
      s.add_development_dependency(%q<json>, [">= 1.7.7"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0.3.8"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 3.1.0"])
      s.add_development_dependency(%q<test-unit>, ["~> 3.1.0"])
    else
      s.add_dependency(%q<oauth>, [">= 0.4.4", "~> 0.4"])
      s.add_dependency(%q<oauth2>, [">= 0.8.0"])
      s.add_dependency(%q<bcrypt>, ["~> 3.1"])
      s.add_dependency(%q<abstract>, [">= 1.0.0"])
      s.add_dependency(%q<json>, [">= 1.7.7"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0.3.8"])
      s.add_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_dependency(%q<rspec-rails>, ["~> 3.1.0"])
      s.add_dependency(%q<test-unit>, ["~> 3.1.0"])
    end
  else
    s.add_dependency(%q<oauth>, [">= 0.4.4", "~> 0.4"])
    s.add_dependency(%q<oauth2>, [">= 0.8.0"])
    s.add_dependency(%q<bcrypt>, ["~> 3.1"])
    s.add_dependency(%q<abstract>, [">= 1.0.0"])
    s.add_dependency(%q<json>, [">= 1.7.7"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0.3.8"])
    s.add_dependency(%q<rspec>, ["~> 3.1.0"])
    s.add_dependency(%q<rspec-rails>, ["~> 3.1.0"])
    s.add_dependency(%q<test-unit>, ["~> 3.1.0"])
  end
end
