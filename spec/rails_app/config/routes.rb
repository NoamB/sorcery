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
    get :test_login_from
    get :test_login_from_twitter
    get :test_login_from_facebook
    get :test_login_from_github
    get :test_login_from_google
    get :test_login_from_liveid
    get :test_login_from_vk
    get :test_login_from_jira
    get :test_login_from_salesforce
    get :login_at_test
    get :login_at_test_twitter
    get :login_at_test_facebook
    get :login_at_test_github
    get :login_at_test_google
    get :login_at_test_liveid
    get :login_at_test_vk
    get :login_at_test_jira
    get :login_at_test_salesforce
    get :test_return_to_with_external
    get :test_return_to_with_external_twitter
    get :test_return_to_with_external_facebook
    get :test_return_to_with_external_github
    get :test_return_to_with_external_google
    get :test_return_to_with_external_liveid
    get :test_return_to_with_external_vk
    get :test_return_to_with_external_jira
    get :test_return_to_with_external_salesforce
    get :test_http_basic_auth
    get :some_action_making_a_non_persisted_change_to_the_user
    post :test_login_with_remember
    get :test_create_from_provider_with_block
    get :login_at_test_with_state
  end
end
