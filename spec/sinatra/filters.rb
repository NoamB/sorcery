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