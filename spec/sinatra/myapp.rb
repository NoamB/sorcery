require 'sinatra'
enable :sessions

require 'sqlite3'
require 'active_record'

# establish connection
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:",
  :verbosity => "quiet"
)

require 'action_mailer'

# models
require File.join(File.dirname(__FILE__),'user')
require 'sorcery'

APP_ROOT = File.dirname(__FILE__)

# --- before filters

['/test_logout','/some_action','/test_should_be_logged_in'].each do |patt|
  before patt do
    require_login
  end
end

before '/test_http_basic_auth' do
  require_login_from_http_basic
end

# -----

get '/' do

end

get '/test_login' do
  @user = login(params[:username],params[:password])
  @current_user = current_user
  @logged_in = logged_in?
  erb :test_login
end

get '/test_logout' do
  session[:user_id] = User.first.id
  logout
  @current_user = current_user
  @logged_in = logged_in?
end

get '/test_current_user' do
  session[:user_id] = params[:id]
  current_user
end

get '/some_action' do
  erb ''
end

post '/test_return_to' do
  session[:return_to_url] = params[:return_to_url] if params[:return_to_url]
  @user = login(params[:username], params[:password])
  return_or_redirect_to(:some_action)
end

get '/test_should_be_logged_in' do
  erb ''
end

def test_not_authenticated_action
  halt "test_not_authenticated_action"
end

def not_authenticated2
  @session = session
  save_instance_vars
  redirect '/'
end

# remember me

post '/test_login_with_remember' do
  @user = login(params[:username], params[:password])
  remember_me!
  erb ''
end

# http_basic

get '/test_http_basic_auth' do
  erb "HTTP Basic Auth"
end