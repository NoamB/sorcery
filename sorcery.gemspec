Gem::Specification.new do |s|
  s.name = "sorcery"
  s.version = "0.8.2"
  s.authors = ["Noam Ben Ari"]
  s.email = "nbenari@gmail.com"
  s.description = "Provides common authentication needs such as signing in/out, activating by email and resetting password."
  s.summary = "Magical authentication for Rails 3 applications"
  s.homepage = "http://github.com/NoamB/sorcery"

  s.files         = `git ls-files`.split($/)
  s.require_paths = ["lib"]

  s.licenses = ["MIT"]

  s.add_dependency(%q<oauth>, ["~> 0.4.4"])
  s.add_dependency(%q<oauth2>, ["~> 0.8.0"])
  s.add_dependency(%q<bcrypt-ruby>, ["~> 3.0.0"])

  s.add_development_dependency(%q<abstract>, [">= 1.0.0"])
  s.add_development_dependency(%q<rails>, [">= 3.0.0"])
  s.add_development_dependency(%q<json>, [">= 1.7.7"])
  s.add_development_dependency(%q<rspec>, ["~> 2.5.0"])
  s.add_development_dependency(%q<rspec-rails>, ["~> 2.5.0"])
  s.add_development_dependency(%q<sqlite3>, [">= 0"])
  s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
  s.add_development_dependency(%q<bundler>, [">= 1.1.0"])
  s.add_development_dependency(%q<simplecov>, [">= 0.3.8"])
  s.add_development_dependency(%q<timecop>, [">= 0"])
  s.add_development_dependency(%q<mongo_mapper>, [">= 0"])
  s.add_development_dependency(%q<mongoid>, ["~> 2.4.4"])
end

