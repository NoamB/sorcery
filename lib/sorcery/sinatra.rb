ActiveRecord::Base.send(:include, Sorcery::Model) if defined?(ActiveRecord)
if defined?(Sinatra::Base)
  Sinatra::Base.send(:include, Sorcery::Controller::Adapters::Sinatra)
  Sinatra::Base.send(:include, Sorcery::Controller)
  # Sorcery::Controller::Config.class_eval do
  #   class << self
  #     def submodules=(mods)
  #       @submodules = mods
  #       Sinatra::Base.send(:include, Sorcery::Controller::Adapters::Sinatra)
  #       Sinatra::Base.send(:include, Sorcery::Controller)
  #     end
  #   end
  # end
end