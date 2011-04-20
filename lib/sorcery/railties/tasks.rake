require 'fileutils'

namespace :sorcery do
  desc "Adds sorcery's initializer file"
  task :bootstrap do
    src = File.join(File.dirname(__FILE__), '..', 'initializers', 'initializer.rb')
    target = File.join(Rails.root, "config", "initializers", "sorcery.rb")
    FileUtils.cp(src, target)
  end
end