require 'bundler'
require 'bundler/setup'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "sorcery"
  gem.homepage = "http://github.com/NoamB/sorcery"
  gem.license = "MIT"
  gem.summary = "Magical authentication for Rails 3 applications"
  gem.description = "Provides common authentication needs such as signing in/out, activating by email and resetting password."
  gem.email = "nbenari@gmail.com"
  gem.authors = ["Noam Ben Ari"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'yard'
YARD::Rake::YardocTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
