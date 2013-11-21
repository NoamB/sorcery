AppRoot::Application.routes.draw do
  root :to => "application#index"

  controller :sorcery do
    get :test_login
    get :test_logout
    get :some_action
    post :test_return_to
    get :test_auto_login
    post :test_login_with_remember_in_login
    get :test_login_from_cookie
    get :test_login_from
    get :test_logout_with_remember
    get :test_should_be_logged_in
    get :test_create_from_provider
    get :test_add_second_provider
    get :test_return_to_with_external
    get :test_login_from5
    get :test_login_from4
    get :test_login_from2
    get :test_login_from3
    get :test_return_to_with_external5
    get :login_at_test2
    get :login_at_test3
    get :login_at_test4
    get :test_return_to_with_external2
    get :test_return_to_with_external3
    get :test_return_to_with_external4
    get :test_http_basic_auth
    get :some_action_making_a_non_persisted_change_to_the_user
    post :test_login_with_remember
    get :test_create_from_provider_with_block
    get :login_at_test
    get :login_at_test5
    get :login_at_test_with_state
  end
end
