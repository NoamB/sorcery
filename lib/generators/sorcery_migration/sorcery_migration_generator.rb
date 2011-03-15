require 'rails/generators'
require 'rails/generators/migration'

class SorceryMigrationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  source_root File.join(File.dirname(__FILE__), 'templates')
  argument :submodules, :type => :array, :required => true
  
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.new.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end
  
  def create_migration_file
    self.submodules.each do |submodule|
      migration_template "#{submodule}.rb", "db/migrate/sorcery_#{submodule}.rb"
      sleep 1 # for the timestamp to change
    end
  end
end