require 'oauth'

class SorceryController < ActionController::Base
  protect_from_forgery

  #before_filter :validate_session, :only => [:test_should_be_logged_in] if defined?(:validate_session)
  before_filter :require_login_from_http_basic, :only => [:test_http_basic_auth]
  before_filter :require_login, :only => [:test_logout, :test_should_be_logged_in, :some_action]

  def index
  end

  def some_action
    render :nothing => true
  end

  def some_action_making_a_non_persisted_change_to_the_user
    current_user.email = "to_be_ignored"
    render :nothing => true
  end

  def test_login
    @user = login(params[:email], params[:password])
    render :text => ""
  end

  def test_auto_login
    @user = User.find(:first)
    auto_login(@user)
    @result = current_user
    render :text => ""
  end

  def test_return_to
    @user = login(params[:email], params[:password])
    redirect_back_or_to(:index, :notice => 'haha!')
  end

  def test_logout
    logout
    render :text => ""
  end

  def test_logout_with_remember
    remember_me!
    logout
    render :text => ""
  end

  def test_login_with_remember
    @user = login(params[:email], params[:password])
    remember_me!

    render :text => ""
  end

  def test_login_with_remember_in_login
    @user = login(params[:email], params[:password], params[:remember])

    render :text => ""
  end

  def test_login_from_cookie
    @user = current_user
    render :text => ""
  end

  def test_not_authenticated_action
    render :text => "test_not_authenticated_action"
  end

  def test_should_be_logged_in
    render :text => ""
  end

  def test_http_basic_auth
    render :text => "HTTP Basic Auth"
  end

  def login_at_test
    login_at(:twitter)
  end

  def login_at_test2
    login_at(:facebook)
  end

  def login_at_test3
    login_at(:github)
  end

  def login_at_test4
    login_at(:google)
  end

  def login_at_test5
    login_at(:liveid)
  end

  def login_at_test_with_state
    login_at(:facebook, {:state => "bla"})
  end

  def test_login_from
    if @user = login_from(:twitter)
      redirect_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_login_from2
    if @user = login_from(:facebook)
      redirect_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_login_from3
    if @user = login_from(:github)
      redirect_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_login_from4
    if @user = login_from(:google)
      redirect_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_login_from5
    if @user = login_from(:liveid)
      redirect_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_return_to_with_external
    if @user = login_from(:twitter)
      redirect_back_or_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_return_to_with_external2
    if @user = login_from(:facebook)
      redirect_back_or_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_return_to_with_external3
    if @user = login_from(:github)
      redirect_back_or_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_return_to_with_external4
    if @user = login_from(:google)
      redirect_back_or_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_return_to_with_external5
    if @user = login_from(:liveid)
      redirect_back_or_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

  def test_create_from_provider
    provider = params[:provider]
    login_from(provider)
    if @user = create_from(provider)
      redirect_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
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
      User.where(:email => user.email).empty?
    end
    if @user
      redirect_to "bla", :notice => "Success!"
    else
      redirect_to "blu", :alert => "Failed!"
    end
  end

end
