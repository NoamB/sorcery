Gem::Specification.new do |s|
  s.name = "sorcery"
  s.version = "0.8.5"
  s.authors = ["Noam Ben Ari", "Kir Shatrov"]
  s.email = "nbenari@gmail.com"
  s.description = "Provides common authentication needs such as signing in/out, activating by email and resetting password."
  s.summary = "Magical authentication for Rails 3 applications"
  s.homepage = "http://github.com/NoamB/sorcery"

  s.files         = `git ls-files`.split($/)
  s.require_paths = ["lib"]

  s.licenses = ["MIT"]

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency("oauth", "~> 0.4.4")
  s.add_dependency("oauth2", ">= 0.8.0", "< 1.0.0")
  s.add_dependency("bcrypt-ruby", ">= 3.0")

  s.add_development_dependency("abstract", ">= 1.0.0")
  s.add_development_dependency("rails", ">= 3.2.15")
  s.add_development_dependency("json", ">= 1.7.7")
  s.add_development_dependency("rspec", "~> 2.5.0")
  s.add_development_dependency("rspec-rails", "~> 2.5.0")
  s.add_development_dependency("sqlite3", ">= 0")
  s.add_development_dependency("yard", "~> 0.6.0")
  s.add_development_dependency("bundler", ">= 1.1.0")
  s.add_development_dependency("simplecov", ">= 0.3.8")
  s.add_development_dependency("timecop", ">= 0")
  s.add_development_dependency("mongo_mapper", ">= 0")
  s.add_development_dependency("mongoid", "~> 2.4.4")
end

