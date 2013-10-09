require 'spec_helper'

describe "the login process", :type => :request do
  before(:all) do
    sorcery_reload!
    create_new_user
  end

  after(:all) do
  end
end
#   it "handles unverified request", :js => true do
#     visit root_path
#     #save_and_open_page
#     fill_in 'Username', :with => 'gizmo1'
#     fill_in 'Password', :with => 'secret'
#     # <input name="authenticity_token" type="hidden" value="+8M9lXnjnhAW/mAuzwI9Mmy6hM+00qZJa8VMQUg+NmM=">
#     page.execute_script("$$('hidden').value='mezuza'")
#     #save_and_open_page
#     click_button 'Login'
#     save_and_open_page
#   end
# end