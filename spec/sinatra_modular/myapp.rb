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
ActionMailer::Base.delivery_method = :test
require File.join(File.dirname(__FILE__),'sorcery_mailer')

# models
require File.join(File.dirname(__FILE__),'user')
require 'sorcery'

APP_ROOT = File.dirname(__FILE__)

require File.join(File.dirname(__FILE__),'filters')

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
  redirect_back_or_to(:some_action)
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

post '/test_login_with_remember_in_login' do
  @user = login(params[:username], params[:password], params[:remember])
  erb ''
end

get '/test_login_from_cookie' do
  @user = current_user
  erb ''
end

# http_basic

get '/test_http_basic_auth' do
  erb "HTTP Basic Auth"
end

# oauth

get '/login_at_test' do
  login_at(:twitter)
end

get '/test_login_from' do
  if @user = login_from(:twitter)
    erb "Success!"
  else
    erb "Failed!"
  end
end

# oauth2

get '/login_at_test2' do
  login_at(:facebook)
end

get '/test_login_from2' do
  if @user = login_from(:facebook)
    erb "Success!"
  else
    erb "Failed!"
  end
end

get '/test_create_from_provider' do
  provider = params[:provider]
  login_from(provider)
  if @user = create_from(provider)
    erb "Success!"
  else
    erb "Failed!"
  end
end