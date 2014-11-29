require 'oauth'

class SorceryController < ActionController::Base
  protect_from_forgery

  before_filter :require_login_from_http_basic, only: [:test_http_basic_auth]
  before_filter :require_login, only: [:test_logout, :test_should_be_logged_in, :some_action]

  def index
  end

  def some_action
    render nothing: true
  end

  def some_action_making_a_non_persisted_change_to_the_user
    current_user.email = 'to_be_ignored'
    render nothing: true
  end

  def test_login
    @user = login(params[:email], params[:password])
    render nothing: true
  end

  def test_auto_login
    @user = User.first
    auto_login(@user)
    @result = current_user
    render nothing: true
  end

  def test_return_to
    @user = login(params[:email], params[:password])
    redirect_back_or_to(:index, notice: 'haha!')
  end

  def test_logout
    logout
    render nothing: true
  end

  def test_logout_with_remember
    remember_me!
    logout
    render nothing: true
  end

  def test_login_with_remember
    @user = login(params[:email], params[:password])
    remember_me!

    render nothing: true
  end

  def test_login_with_remember_in_login
    @user = login(params[:email], params[:password], params[:remember])

    render nothing: true
  end

  def test_login_from_cookie
    @user = current_user
    render nothing: true
  end

  def test_not_authenticated_action
    render text: 'test_not_authenticated_action'
  end

  def test_should_be_logged_in
    render nothing: true
  end

  def test_http_basic_auth
    render text: 'HTTP Basic Auth'
  end

  def login_at_test_twitter
    login_at(:twitter)
  end

  alias :login_at_test :login_at_test_twitter

  def login_at_test_facebook
    login_at(:facebook)
  end

  def login_at_test_github
    login_at(:github)
  end

  def login_at_test_google
    login_at(:google)
  end

  def login_at_test_liveid
    login_at(:liveid)
  end

  def login_at_test_jira
    login_at(:jira)
  end

  def login_at_test_vk
    login_at(:vk)
  end

  def login_at_test_salesforce
    login_at(:salesforce)
  end

  def login_at_test_with_state
    login_at(:facebook, {state: 'bla'})
  end

  def test_login_from_twitter
    if @user = login_from(:twitter)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  alias :test_login_from :test_login_from_twitter

  def test_login_from_facebook
    if @user = login_from(:facebook)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_github
    if @user = login_from(:github)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_google
    if @user = login_from(:google)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_liveid
    if @user = login_from(:liveid)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_vk
    if @user = login_from(:vk)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_jira
    if @user = login_from(:jira)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_login_from_salesforce
    if @user = login_from(:salesforce)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_twitter
    if @user = login_from(:twitter)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_jira
    if @user = login_from(:jira)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  alias :test_return_to_with_external :test_return_to_with_external_twitter

  def test_return_to_with_external_facebook
    if @user = login_from(:facebook)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_github
    if @user = login_from(:github)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_google
    if @user = login_from(:google)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_liveid
    if @user = login_from(:liveid)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_vk
    if @user = login_from(:vk)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_return_to_with_external_salesforce
    if @user = login_from(:salesforce)
      redirect_back_or_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_create_from_provider
    provider = params[:provider]
    login_from(provider)
    if @user = create_from(provider)
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

  def test_add_second_provider
    provider = params[:provider]
    if logged_in?
      if @user = add_provider_to_user(provider)
        redirect_to "bla", :notice => "Success!"
      else
        redirect_to "blu", :alert => "Failed!"
      end
    end
  end

  def test_create_from_provider_with_block
    provider = params[:provider]
    login_from(provider)
    @user = create_from(provider) do |user|
      # check uniqueness of email
      # User.where(email: user.email).empty?
      false
    end
    if @user
      redirect_to 'bla', notice: 'Success!'
    else
      redirect_to 'blu', alert: 'Failed!'
    end
  end

end
