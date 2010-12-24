require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "simple_auth"
  gem.homepage = "http://github.com/NoamB/simple_auth"
  gem.license = "MIT"
  gem.summary = "Simple authentication for Rails 3 applications"
  gem.description = "Provides common authentication needs such as signing in/out, activating by email, resetting password and deleting accounts."
  gem.email = "nbenari@gmail.com"
  gem.authors = ["Noam"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)



require 'yard'
YARD::Rake::YardocTask.new


#task :default => :spec
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
