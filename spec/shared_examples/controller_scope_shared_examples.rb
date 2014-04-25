shared_examples_for 'scoped' do
  before do
    User.scope :without_username, -> {User.where username: ''}
    sorcery_model_property_set(:scope, :without_username)
  end

  it "login(username,password) should look for user within specified scope. User should not be found" do
    create_new_user({:username => "GIZMO1", :email => 'bla1@bla.com', :password => 'secret1'})
    get :test_login, :email => 'bla1@bla.com', :password => 'secret1'
    assigns[:user].should be_nil
    session[:user_id].should be_nil
  end

  it "login(username,password) should look for user within specified scope. User should be found" do
    create_new_user({:username => "", :email => 'bla1@bla.com', :password => 'secret1'})
    get :test_login, :email => 'bla1@bla.com', :password => 'secret1'
    assigns[:user].should == @user
    session[:user_id].should == @user.id
  end
end
