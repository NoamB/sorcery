shared_examples_for "rails_3_remember_me_model" do
  let(:user) { create_new_user }

  describe "loaded plugin configuration" do

    before(:all) do
      sorcery_reload!([:remember_me])
    end
  
    after(:each) do
      User.sorcery_config.reset!
    end
    
    it "allows configuration option 'remember_me_token_attribute_name'" do
      sorcery_model_property_set(:remember_me_token_attribute_name, :my_token)

      expect(User.sorcery_config.remember_me_token_attribute_name).to eq :my_token
    end

    it "allows configuration option 'remember_me_token_expires_at_attribute_name'" do
      sorcery_model_property_set(:remember_me_token_expires_at_attribute_name, :my_expires)

      expect(User.sorcery_config.remember_me_token_expires_at_attribute_name).to eq :my_expires
    end

    it "allows configuration option 'remember_me_token_persist_globally'" do
      sorcery_model_property_set(:remember_me_token_persist_globally, true)

      expect(User.sorcery_config.remember_me_token_persist_globally).to eq true
    end
    
    specify { expect(user).to respond_to :remember_me! }

    specify { expect(user).to respond_to :forget_me! }

    specify { expect(user).to respond_to :force_forget_me! }
    
    it "sets an expiration based on 'remember_me_for' attribute" do
      sorcery_model_property_set(:remember_me_for, 2 * 60 * 60 * 24)

      ts = Time.now.in_time_zone
      Timecop.freeze(ts) do
        user.remember_me!
      end

      expect(user.remember_me_token_expires_at.utc.to_s).to eq (ts + 2 * 60 * 60 * 24).utc.to_s
    end
    
    context "when not persisting globally" do
      before { sorcery_model_property_set(:remember_me_token_persist_globally, false) }

      it "generates a new token on 'remember_me!' when a token doesn't exist" do
        expect(user.remember_me_token).to be_nil
        user.remember_me!

        expect(user.remember_me_token).not_to be_nil
      end

      it "generates a new token on 'remember_me!' when a token exists" do
        user.remember_me_token = "abc123"
        user.remember_me!

        expect(user.remember_me_token).not_to be_nil
        expect(user.remember_me_token).not_to eq("abc123")
      end

      it "deletes the token and expiration on 'forget_me!'" do
        user.remember_me!

        expect(user.remember_me_token).not_to be_nil

        user.forget_me!

        expect(user.remember_me_token).to be_nil
        expect(user.remember_me_token_expires_at).to be_nil
      end

      it "deletes the token and expiration on 'force_forget_me!'" do
        user.remember_me!

        expect(user.remember_me_token).not_to be_nil

        user.force_forget_me!

        expect(user.remember_me_token).to be_nil
        expect(user.remember_me_token_expires_at).to be_nil
      end
    end

    context "when persisting globally" do
      before { sorcery_model_property_set(:remember_me_token_persist_globally, true) }

      it "generates a new token on 'remember_me!' when a token doesn't exist" do
        expect(user.remember_me_token).to be_nil
        user.remember_me!

        expect(user.remember_me_token).not_to be_nil
      end

      it "keeps existing token on 'remember_me!' when a token exists" do
        user.remember_me_token = "abc123"
        user.remember_me!

        expect(user.remember_me_token).to eq("abc123")
      end

      it "keeps the token and expiration on 'forget_me!'" do
        user.remember_me!

        expect(user.remember_me_token).not_to be_nil

        user.forget_me!

        expect(user.remember_me_token).to_not be_nil
        expect(user.remember_me_token_expires_at).to_not be_nil
      end

      it "deletes the token and expiration on 'force_forget_me!'" do
        user.remember_me!

        expect(user.remember_me_token).not_to be_nil

        user.force_forget_me!

        expect(user.remember_me_token).to be_nil
        expect(user.remember_me_token_expires_at).to be_nil
      end
    end

  end
end
