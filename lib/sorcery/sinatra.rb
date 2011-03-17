require 'sorcery'

ActiveRecord::Base.send(:include, Sorcery::Model) if defined?(ActiveRecord)
