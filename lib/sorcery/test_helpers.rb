module Sorcery
  module TestHelpers
    def create_new_user(attributes_hash = nil)
      user_attributes_hash = attributes_hash || {:username => 'gizmo', :email => "bla@bla.com", :password => 'secret'}
      @user = User.new(user_attributes_hash)
      @user.save!
      @user
    end

    def create_new_external_user(provider, attributes_hash = nil)
      user_attributes_hash = attributes_hash || {:username => 'gizmo', :authentications_attributes => [{:provider => provider, :uid => 123}]}
      @user = User.new(user_attributes_hash)
      @user.save!
      @user
    end
    
    def login_user(user = nil)
      user ||= @user
      subject.send(:login_user,user)
      subject.send(:after_login!,user,[user.username,'secret'])
    end

    def logout_user
      subject.send(:logout)
    end

    def clear_user_without_logout
      subject.instance_variable_set(:@current_user,nil)
    end
    
    def sorcery_model_property_set(property, *values)
      User.class_eval do
        sorcery_config.send(:"#{property}=", *values)
      end
    end

    private

    # reload user class between specs
    # so it will be possible to test the different submodules in isolation
    def reload_user_class
      Object.send(:remove_const,:User)
      load 'user.rb'
    end
  end
end