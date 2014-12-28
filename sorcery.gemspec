lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sorcery/version'

Gem::Specification.new do |s|
  s.name = "sorcery"
  s.version = Sorcery::VERSION
  s.authors = ["Noam Ben Ari", "Kir Shatrov", "Grzegorz Witek"]
  s.email = "nbenari@gmail.com"
  s.description = "Provides common authentication needs such as signing in/out, activating by email and resetting password."
  s.summary = "Magical authentication for Rails 3 & 4 applications"
  s.homepage = "http://github.com/NoamB/sorcery"

  s.files         = `git ls-files`.split($/)
  s.require_paths = ["lib"]

  s.licenses = ["MIT"]

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency "oauth", "~> 0.4", ">= 0.4.4"
  s.add_dependency "oauth2", ">= 0.8.0"
  s.add_dependency "bcrypt", "~> 3.1"

  s.add_development_dependency "abstract", ">= 1.0.0"
  s.add_development_dependency "json", ">= 1.7.7"
  s.add_development_dependency "yard", "~> 0.6.0"

  s.add_development_dependency "timecop"
  s.add_development_dependency "simplecov", ">= 0.3.8"
  s.add_development_dependency "rspec", "~> 3.0.0"
  s.add_development_dependency "rspec-rails", "~> 3.0.0"
end

