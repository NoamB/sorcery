require 'sinatra'
require 'active_record'

# establish connection

require 'action_mailer'

# models
require File.join(File.dirname(__FILE__),'user')
require 'sorcery'

APP_ROOT = File.dirname(__FILE__)

get '/' do

end