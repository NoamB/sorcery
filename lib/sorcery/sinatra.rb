ActiveRecord::Base.send(:include, Sorcery::Model) if defined?(ActiveRecord)
if defined?(Sinatra::Base)
  Sinatra::Base.send(:include, Sorcery::Controller::Adapters::Sinatra)
  Sinatra::Base.send(:include, Sorcery::Controller)
end
