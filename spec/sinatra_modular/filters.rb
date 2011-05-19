# --- before filters
module Filters

  def self.included(klass)
    klass.class_eval do
      ['/test_logout', '/some_action', '/test_should_be_logged_in'].each do |pattern|
        before pattern do
          require_login
        end
      end

      before '/test_http_basic_auth' do
        require_login_from_http_basic
      end

      # ----- test filters

      before do
        self.class.sorcery_vars = {}
      end

      after do
        save_instance_vars
      end
    end
  end
end