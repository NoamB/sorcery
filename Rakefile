# require 'bundler'
# begin
#   Bundler.setup(:default, :development)
# rescue Bundler::BundlerError => e
#   $stderr.puts e.message
#   $stderr.puts "Run `bundle install` to install missing gems"
#   exit e.status_code
# end
require 'rake'

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
  gem.add_runtime_dependency 'bcrypt-ruby', '~> 2.1.4'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'yard'
YARD::Rake::YardocTask.new

desc 'Default: Run all specs.'
task :default => :all_specs

desc "Run all specs"
task :all_specs do
  Dir['spec/**/Rakefile'].each do |rakefile|
    directory_name = File.dirname(rakefile)
    sh <<-CMD
      cd #{directory_name}
      bundle exec rake
    CMD
  end
end
