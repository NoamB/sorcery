ActiveRecord::Base.send(:include, Sorcery::Model) if defined?(ActiveRecord)
if defined?(Sinatra::Application)
  Sinatra::Application.send(:include, Sorcery::Controller::Adapters::Sinatra)
  Sinatra::Application.send(:include, Sorcery::Controller)
end
